import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shape_task_connect/models/user.dart';
import 'package:shape_task_connect/services/google_login_service.dart';
import '../repositories/user_repository.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _lastUserKey = 'last_logged_in_user';
  static const String _biometricEnabledKey = 'biometric_enabled';
  final UserRepository _userRepository;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  bool _isLoggedIn = false;
  User? _currentUserDetails;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SharedPreferences _prefs;

  AuthService(this._userRepository, this._prefs);

  User? get currentUserDetails {
    firebase_auth.User? currentFirebaseUser = _firebaseAuth.currentUser;
    if (currentFirebaseUser == null) {
      return null;
    }

    return User(
        uid: currentFirebaseUser.uid,
        email: currentFirebaseUser.email ?? '',
        displayName: currentFirebaseUser.displayName ?? '');
  }

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
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _isLoggedIn = true;
        _currentUserDetails = await _userRepository.getUserByEmail(email);
        await _prefs.setString(_lastUserKey, email);
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Failed to login: ${e.message}');
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    try {
      // First create the user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(username);

      // Create user in Firestore
      final user = User(
        uid: userCredential.user!.uid,
        email: email,
        displayName: username,
      );

      await _userRepository.createUser(user);

      return userCredential.user != null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        case 'email-already-in-use':
          throw Exception('An account already exists for that email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception(e.message ?? 'Registration failed.');
      }
    } catch (e) {
      throw Exception('Failed to register user.');
    }
  }

  Future<bool> loginWithGoogle() async {
    final googleOuthService = GoogleOuthService();
    final googleUser = await googleOuthService.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth == null) {
      return false;
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    User? user =
        await _userRepository.getUserByEmail(userCredential.user!.email!);
    if (user == null) {
      await _userRepository.createUser(User(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        displayName: userCredential.user!.displayName!,
      ));
      user = await _userRepository.getUserByEmail(userCredential.user!.email!);
    }
    if (user != null) {
      _isLoggedIn = true;
      _currentUserDetails = user;
      await _prefs.setString(_lastUserKey, userCredential.user!.email!);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await GoogleOuthService().signOut();
    _isLoggedIn = false;
    // Don't remove _lastUserKey or biometric settings
  }

  Future<bool> canUseBiometrics() async {
    try {
      // First check if the device supports biometrics
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        return false;
      }

      // Then check for available biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      // For Android simulator debugging
      print('Available biometrics: $availableBiometrics');
      print('Can authenticate with biometrics: $canAuthenticateWithBiometrics');
      print('Device supported: ${await _localAuth.isDeviceSupported()}');

      // Check if any biometric is actually enrolled
      return availableBiometrics.isNotEmpty &&
          (availableBiometrics.contains(BiometricType.face) ||
              availableBiometrics.contains(BiometricType.fingerprint) ||
              availableBiometrics.contains(BiometricType.strong) ||
              availableBiometrics.contains(BiometricType.weak));
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  Future<String> getBiometricType() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      }
      return 'Biometrics';
    } catch (e) {
      return 'Biometrics';
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

      final biometricType = await getBiometricType();
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate using your $biometricType',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate && lastUser != null) {
        _isLoggedIn = true;
        //_currentUserDetails = await _userRepository.getUserByEmail(lastUser);
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
