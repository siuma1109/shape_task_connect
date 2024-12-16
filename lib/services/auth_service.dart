import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  Future<bool> register(String email, String password) async {
    // TODO: Implement actual API registration
    // This is a mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> login(String email, String password) async {
    // TODO: Implement actual API login
    // This is a mock implementation
    await Future.delayed(const Duration(seconds: 1));
    await _saveToken('mock_token');
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }
}
