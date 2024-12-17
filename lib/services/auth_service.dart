import '../repositories/user_repository.dart';
import '../models/user.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _lastUserKey = 'last_logged_in_user';
  static const String _biometricEnabledKey = 'biometric_enabled';
  final UserRepository _userRepository;
  bool _isLoggedIn = false;
  User? _currentUserDetails;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SharedPreferences _prefs;

  AuthService(this._userRepository, this._prefs);

  User? get currentUserDetails => _currentUserDetails;

  Future<bool> checkLoginStatus() async {
    return _isLoggedIn;
  }

  Future<bool> isBiometricEnabled() async {
    final lastUser = _prefs.getString(_lastUserKey);
    return lastUser != null &&
        _prefs.getBool('${_biometricEnabledKey}_$lastUser') == true;
  }

  Future<void> enableBiometric() async {
    final lastUser = _prefs.getString(_lastUserKey);
    if (lastUser != null) {
      await _prefs.setBool('${_biometricEnabledKey}_$lastUser', true);
    }
  }

  Future<void> disableBiometric() async {
    final lastUser = _prefs.getString(_lastUserKey);
    if (lastUser != null) {
      await _prefs.setBool('${_biometricEnabledKey}_$lastUser', false);
    }
  }

  Future<bool> login(String email, String password) async {
    bool isValid = await _userRepository.validateUser(email, password);
    if (isValid) {
      _isLoggedIn = true;
      _currentUserDetails = await _userRepository.getUserByEmail(email);
      await _prefs.setString(_lastUserKey, email);
    }
    return isValid;
  }

  Future<bool> register(String email, String username, String password) async {
    final user = User(email: email, username: username, password: password);
    return await _userRepository.createUser(user);
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    // Don't remove _lastUserKey or biometric settings
  }

  Future<bool> canUseBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final lastUser = _prefs.getString(_lastUserKey);
      final isBiometricEnabled = lastUser != null &&
          _prefs.getBool('${_biometricEnabledKey}_$lastUser') == true;

      if (!isBiometricEnabled) {
        throw Exception('biometric_not_setup');
      }

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate && lastUser != null) {
        _isLoggedIn = true;
        _currentUserDetails = await _userRepository.getUserByEmail(lastUser);
        return true;
      }
      return false;
    } catch (e) {
      if (e.toString().contains('biometric_not_setup')) {
        throw Exception('Please login first to setup biometric authentication');
      }
      return false;
    }
  }
}
