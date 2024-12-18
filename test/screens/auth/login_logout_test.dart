import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shape_task_connect/services/auth_service.dart';
import 'package:shape_task_connect/screens/auth/login_screen.dart';
import 'package:shape_task_connect/screens/home/home_screen.dart';

@GenerateNiceMocks([MockSpec<AuthService>()])
import 'login_logout_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('Login and logout flow test', (WidgetTester tester) async {
    // Setup mock behavior
    when(mockAuthService.login(any, any)).thenAnswer((_) async => true);
    when(mockAuthService.logout()).thenAnswer((_) async => {});
    when(mockAuthService.enableBiometric()).thenAnswer((_) async => {});

    // Build login screen
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authService: mockAuthService),
        routes: {
          '/home': (context) => HomeScreen(
                title: 'Home',
                authService: mockAuthService,
              ),
          '/login': (context) => LoginScreen(authService: mockAuthService),
        },
      ),
    );

    // Verify login screen is shown
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);

    // Enter login credentials
    await tester.enterText(
        find.widgetWithIcon(TextFormField, CupertinoIcons.mail),
        'test@example.com');
    await tester.enterText(
        find.widgetWithIcon(TextFormField, CupertinoIcons.lock), 'password123');

    // Tap login button
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    // Verify biometric setup dialog appears
    expect(find.text('Enable Biometric Login'), findsOneWidget);
    expect(
      find.text(
          'Would you like to enable fingerprint login for faster access?'),
      findsOneWidget,
    );

    // Tap "No" on the dialog
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    // Verify biometric was not enabled
    verifyNever(mockAuthService.enableBiometric());

    // Verify we're on the home screen
    expect(find.text('Home'), findsOneWidget);

    // Verify login was called with correct credentials
    verify(mockAuthService.login('test@example.com', 'password123')).called(1);

    // Find and tap logout button
    await tester.tap(find.byIcon(CupertinoIcons.square_arrow_right));
    await tester.pumpAndSettle();

    // Verify logout was called
    verify(mockAuthService.logout()).called(1);

    // Verify we're back on login screen
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Login failure shows error message', (WidgetTester tester) async {
    // Setup mock behavior for failed login
    when(mockAuthService.login(any, any)).thenAnswer((_) async => false);

    // Build login screen
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authService: mockAuthService),
      ),
    );

    // Enter login credentials
    await tester.enterText(
        find.widgetWithIcon(TextFormField, CupertinoIcons.mail),
        'test@example.com');
    await tester.enterText(
        find.widgetWithIcon(TextFormField, CupertinoIcons.lock), 'password123');

    // Tap login button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.text('Login failed. Please check your email and password'),
        findsOneWidget);
  });
}
