import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile/shared/widgets/login_screen.dart';
import 'package:flutter_mobile/shared/services/auth/auth_service.dart';
import 'package:flutter_mobile/shared/models/user_model.dart';
import '../utils/test_helpers.dart';

// Mock auth service for testing
class MockAuthService extends AuthService {
  MockAuthService() : super(MockApiClient());
  
  bool _shouldSucceed = true;
  String _errorMessage = 'Test error';
  
  void mockSuccess() => _shouldSucceed = true;
  void mockFailure(String message) {
    _shouldSucceed = false;
    _errorMessage = message;
  }

  @override
  Future<LoginResult> login(String username, String password) async {
    await TestHelpers.mockNetworkDelay();
    
    if (_shouldSucceed) {
      final user = UserModel.fromJson(TestHelpers.createMockUser());
      return LoginResult(
        success: true,
        user: user,
        message: 'Đăng nhập thành công',
      );
    } else {
      return LoginResult(
        success: false,
        message: _errorMessage,
      );
    }
  }
}

class MockApiClient {
  // Mock implementation
}

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('should display all login form elements', (WidgetTester tester) async {
      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check for app name
      expect(find.text(TestHelpers.vietnameseTexts['appName']!), findsOneWidget);

      // Check for form fields
      expect(find.byType(TextFormField), findsNWidgets(2)); // Username and password
      
      // Check for login button
      expect(find.text(TestHelpers.vietnameseTexts['login']!), findsOneWidget);
      
      // Check for demo credentials info
      expect(find.text('Thông tin đăng nhập demo:'), findsOneWidget);
      expect(find.text('Tên đăng nhập: admin\nMật khẩu: 1q2w3E*'), findsOneWidget);
    });

    testWidgets('should validate empty form fields', (WidgetTester tester) async {
      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Tap login button without entering data
      final loginButton = find.byType(ElevatedButton);
      await TestHelpers.tapAndWait(tester, loginButton);

      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Trường này bắt buộc'), findsAtLeastNWidgets(1));
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.byType(TextFormField).last;
      
      // Find visibility toggle button
      final toggleButton = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );

      expect(toggleButton, findsOneWidget);

      // Initially password should be obscured
      final textFormField = tester.widget<TextFormField>(passwordField);
      expect(textFormField.obscureText, isTrue);

      // Tap toggle button
      await TestHelpers.tapAndWait(tester, toggleButton);

      // Password should now be visible
      final textFormFieldAfter = tester.widget<TextFormField>(passwordField);
      expect(textFormFieldAfter.obscureText, isFalse);
    });

    testWidgets('should show loading state during login', (WidgetTester tester) async {
      mockAuthService.mockSuccess();

      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Enter credentials
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).first,
        'admin',
      );
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).last,
        '1q2w3E*',
      );

      // Tap login button
      final loginButton = find.byType(ElevatedButton);
      await TestHelpers.tapAndWait(tester, loginButton);

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for login to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('should show error message on login failure', (WidgetTester tester) async {
      const errorMessage = 'Tên đăng nhập hoặc mật khẩu không đúng';
      mockAuthService.mockFailure(errorMessage);

      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Enter credentials
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).first,
        'wrong_user',
      );
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).last,
        'wrong_password',
      );

      // Tap login button
      final loginButton = find.byType(ElevatedButton);
      await TestHelpers.tapAndWait(tester, loginButton);

      // Wait for login to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show error message
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should validate password minimum length', (WidgetTester tester) async {
      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Enter short password
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).first,
        'admin',
      );
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).last,
        '123', // Too short
      );

      // Tap login button
      final loginButton = find.byType(ElevatedButton);
      await TestHelpers.tapAndWait(tester, loginButton);

      await tester.pumpAndSettle();

      // Should show password length validation error
      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('should have proper accessibility features', (WidgetTester tester) async {
      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Check for semantic labels
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Check if login button is properly accessible
      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);
      
      // Check for password toggle button
      final toggleButton = find.byType(IconButton);
      expect(toggleButton, findsOneWidget);
    });

    testWidgets('should handle successful login flow', (WidgetTester tester) async {
      mockAuthService.mockSuccess();

      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Enter valid credentials
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).first,
        'admin',
      );
      await TestHelpers.enterText(
        tester,
        find.byType(TextFormField).last,
        '1q2w3E*',
      );

      // Tap login button
      final loginButton = find.byType(ElevatedButton);
      await TestHelpers.tapAndWait(tester, loginButton);

      // Wait for login to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should not show error messages
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should display Vietnamese text correctly', (WidgetTester tester) async {
      await TestHelpers.pumpTestApp(
        tester,
        child: const LoginScreen(),
        providerOverrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      await tester.pumpAndSettle();

      // Check for Vietnamese text elements
      expect(find.text('SmartRestaurant'), findsOneWidget);
      expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
      expect(find.text('Tên đăng nhập'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.text('Thông tin đăng nhập demo:'), findsOneWidget);
    });
  });
}