import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:shape_task_connect/services/google_login_service.dart';

// Generate mock for GoogleSignIn
@GenerateNiceMocks([MockSpec<GoogleSignIn>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoogleOuthService googleOuthService;

  setUp(() {
    // Set up platform channel mock
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/google_sign_in');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'init':
            return null;
          case 'signIn':
            return {
              'email': 'test@test.com',
              'id': '123',
              'displayName': 'Test User',
              'photoUrl': 'https://test.com/photo.jpg',
            };
          case 'signOut':
            return null;
          default:
            return null;
        }
      },
    );

    googleOuthService = GoogleOuthService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_sign_in'),
      null,
    );
  });

  group('GoogleOuthService', () {
    test('signIn - should update currentUser when successful', () async {
      // Act
      final result = await googleOuthService.signIn();

      // Assert
      expect(result, isA<GoogleSignInAccount?>());
      expect(googleOuthService.currentUser, equals(result));
    });

    test('signOut - should clear currentUser', () async {
      // Act
      final result = await googleOuthService.signOut();

      // Assert
      expect(result, isNull);
      expect(googleOuthService.currentUser, isNull);
    });

    test('currentUser - should return null initially', () {
      expect(googleOuthService.currentUser, isNull);
    });
  });
}
