import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return true; // Si pas supporté, on laisse passer (pour la V1)
      
      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à vos documents',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      print("Erreur d'authentification: $e");
      return false;
    }
  }
}
