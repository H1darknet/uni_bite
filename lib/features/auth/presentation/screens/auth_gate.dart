
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../kitchen/presentation/screens/kitchen_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        final role = auth.user?.role;

        if (role == 'staff' || role == 'admin') {
          return const KitchenScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
