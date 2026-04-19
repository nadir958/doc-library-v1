import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(SettingsState(
    themeMode: ThemeMode.values[_prefs.getInt('themeMode') ?? 0],
    locale: _prefs.getString('locale') != null ? Locale(_prefs.getString('locale')!) : null,
  ));

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setInt('themeMode', mode.index);
  }

  void setLocale(Locale? locale) {
    state = state.copyWith(locale: locale);
    if (locale == null) {
      _prefs.remove('locale');
    } else {
      _prefs.setString('locale', locale.languageCode);
    }
  }
}

class SettingsState {
  final ThemeMode themeMode;
  final Locale? locale;

  SettingsState({required this.themeMode, this.locale});

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
