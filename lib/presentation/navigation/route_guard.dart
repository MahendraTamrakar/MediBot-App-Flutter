import 'package:flutter/material.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';


/// Authentication guard
/// 
/// Wraps protected screens and redirects to sign in if not authenticated.
/// 
/// Usage:
/// ```dart
/// MaterialPageRoute(
///   builder: (_) => const AuthGuard(child: HomeScreen()),
/// )
/// ```
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Still checking initial auth state
        if (authProvider.isInitializing) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Not authenticated → redirect to sign in
        if (authProvider.isUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.signIn);
            }
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Authenticated → show protected content
        return child;
      },
    );
  }
}

/// Guest guard (redirects authenticated users away from auth screens)
/// 
/// Wraps authentication screens and redirects to home if already logged in.
/// 
/// Usage:
/// ```dart
/// MaterialPageRoute(
///   builder: (_) => const GuestGuard(child: SignInScreen()),
/// )
/// ```
class GuestGuard extends StatelessWidget {
  final Widget child;

  const GuestGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Already authenticated → redirect to home
        if (authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Not authenticated → show auth screen
        return child;
      },
    );
  }
}

/// Email verification guard
/// 
/// Wraps screens that require verified email and shows verification prompt.
/// 
/// Usage:
/// ```dart
/// MaterialPageRoute(
///   builder: (_) => const EmailVerificationGuard(child: SensitiveScreen()),
/// )
/// ```
class EmailVerificationGuard extends StatelessWidget {
  final Widget child;

  const EmailVerificationGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        // Email not verified → show verification screen
        if (user != null && !user.emailVerified) {
          return Scaffold(
            appBar: AppBar(title: const Text('Email Verification Required')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Please verify your email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We sent a verification link to ${user.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Resend verification email
                      },
                      child: const Text('Resend Verification Email'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        authProvider.refreshUser();
                      },
                      child: const Text('I\'ve verified my email'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Email verified → show protected content
        return child;
      },
    );
  }
}