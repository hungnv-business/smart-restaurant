import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth/auth_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';

/// Widget wrapper kiểm tra authentication state và điều hướng phù hợp
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Delay auth check until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  /// Kiểm tra authentication state khi khởi động ứng dụng
  Future<void> _checkAuthState() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Kiểm tra nếu có saved token trong persistent storage
    await authService.checkSavedAuthState();
    
    // Kiểm tra token expiration và refresh nếu cần
    if (authService.isLoggedIn && authService.isTokenExpired()) {
      try {
        await authService.refreshToken();
      } catch (e) {
        // Nếu refresh token thất bại, logout
        await authService.logout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Hiển thị loading spinner khi đang kiểm tra auth state
        if (authService.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.sports_bar,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang kiểm tra đăng nhập...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // Redirect dựa trên authentication state
        if (authService.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}