import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/screens/main_app_shell.dart';
// import 'package:selman/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We use Consumer to listen to changes in AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          // If the user is authenticated, show the main app
          return const MainAppShell();
        } else {
          // If not, show the LoginScreen
          // For now, we'll just use a placeholder
          return const Scaffold(
              body: Center(child: Text('Login Screen Placeholder')));
          // return const LoginScreen();
        }
      },
    );
  }
}
