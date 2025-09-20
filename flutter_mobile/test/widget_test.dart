import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobile/core/services/auth/auth_service.dart';
import 'package:flutter_mobile/features/auth/screens/login_screen.dart';
import 'package:flutter_mobile/core/themes/app_theme.dart';

void main() {
  testWidgets('Login screen loads correctly', (WidgetTester tester) async {
    // Build our app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    // Verify that login screen loads with correct elements
    expect(find.text('Quán bia'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}