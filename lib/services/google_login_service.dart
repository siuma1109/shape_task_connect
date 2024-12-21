import 'package:google_sign_in/google_sign_in.dart';

class GoogleOuthService {
  final scopes = ['email', 'profile'];
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    final GoogleSignInAccount? user = await _googleSignIn.signIn();
    _currentUser = user;
    return user;
  }

  Future<GoogleSignInAccount?> signOut() async {
    final GoogleSignInAccount? user = await _googleSignIn.signOut();
    _currentUser = null;
    return user;
  }
}
