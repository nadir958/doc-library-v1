import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/biometric_service.dart';
import 'settings_provider.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class AuthNotifier extends StateNotifier<bool> with WidgetsBindingObserver {
  final BiometricService _biometricService;
  final Ref _ref;

  AuthNotifier(this._biometricService, this._ref) : super(false) {
    WidgetsBinding.instance.addObserver(this);
    // On n'authentifie pas tout de suite ici, on attend que l'UI le demande
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si l'application passe en arrière-plan, on verrouille si la biométrie est activée
    final settings = _ref.read(settingsProvider);
    if (settings.isBiometricEnabled && (state == AppLifecycleState.paused || state == AppLifecycleState.inactive)) {
      lock();
    }
  }

  void lock() {
    state = false;
  }

  Future<bool> authenticate() async {
    final settings = _ref.read(settingsProvider);
    
    // Si la biométrie n'est pas activée, on est toujours "authentifié"
    if (!settings.isBiometricEnabled) {
      state = true;
      return true;
    }

    final success = await _biometricService.authenticate();
    if (success) {
      state = true;
    }
    return success;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final service = ref.watch(biometricServiceProvider);
  return AuthNotifier(service, ref);
});
