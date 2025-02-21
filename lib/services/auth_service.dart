import 'package:local_auth/local_auth.dart';

class AuthService {
  static final LocalAuthentication auth = LocalAuthentication();

  // Simulated login: requires an email containing "@" and a password of at least 6 characters.
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    return email.contains('@') && password.length >= 6;
  }

  // Simulated account creation: requires email, password, and a selected school.
  Future<bool> createAccount(
    String email,
    String password,
    String school,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    return email.contains('@') && password.length >= 6 && school.isNotEmpty;
  }

  // Use local_auth for biometric authentication.
  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        biometricOnly: true,
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  // Simulated password reset.
  Future<void> resetPassword(String email) async {
    await Future.delayed(Duration(seconds: 1));
  }
}
