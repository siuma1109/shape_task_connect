import '../repositories/user_repository.dart';
import '../models/user.dart';

class AuthService {
  final UserRepository _userRepository;
  String? _currentUser;

  AuthService(this._userRepository);

  String? get currentUser => _currentUser;

  Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }

  Future<bool> login(String email, String password) async {
    bool isValid = await _userRepository.validateUser(email, password);
    if (isValid) {
      _currentUser = email;
    }
    return isValid;
  }

  Future<bool> register(String email, String password) async {
    final user = User(email: email, password: password);
    return await _userRepository.createUser(user);
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
