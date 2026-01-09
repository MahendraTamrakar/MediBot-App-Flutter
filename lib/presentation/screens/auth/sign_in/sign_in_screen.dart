import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medibot/presentation/common_widgets/input/custom_text_field.dart';
import 'package:medibot/presentation/common_widgets/input/password_field.dart';
import 'package:medibot/presentation/common_widgets/loaders/loading_indicator.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:medibot/presentation/common_widgets/buttons/primary_buttons.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //sign in with email
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome back!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.chat);
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: const Color.fromARGB(255, 249, 79, 67)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //sign in with google
  Future<void> _signInWithGoogle() async {
    try {
      final authProvider = context.read<AuthProvider>();

      final user = await authProvider.signInWithGoogle();

      if (user == null) {
        // User cancelled Google Sign-In
        return;
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in with Google!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      Navigator.pushReplacementNamed(context, AppRoutes.chat);
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 255, 253, 254),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height,
            child: Image.asset(
              'assets/images/sign_in.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
      
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.75,
                minHeight: size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark 
                        ? const Color(0xFF343541) 
                        : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'cursive',
                            color:
                                theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : theme.primaryColor,
                          ),
                        ),
      
                        const SizedBox(height: 20),
      
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
      
                        const SizedBox(height: 18),
      
                        PasswordField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
      
                        //const SizedBox(height: 2),
      
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.forgotPassword,
                              );
                            },
                            child: Text('Forgot Password?',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400
                            ),),
                          ),
                        ),
      
                        const SizedBox(height: 10),
      
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final isLoading =
                                authProvider.isLoading || _isLoading;
      
                            return isLoading
                                ? const LoadingIndicator()
                                : PrimaryButton(
                                  text: 'Sign In',
                                  onPressed: _signInWithEmail,
                                  isLoading: authProvider.isLoading,
                                );
                          },
                        ),
      
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color:
                                    theme.brightness == Brightness.dark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.signUp,
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
      
                        const Text(
                          "or",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
      
                        const SizedBox(height: 10),
      
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _signInWithGoogle,
                              icon: Image.asset(
                                'assets/images/google.png',
                                width: 48,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
