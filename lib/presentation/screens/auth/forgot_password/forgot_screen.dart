import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medibot/presentation/common_widgets/buttons/primary_buttons.dart';
import 'package:medibot/presentation/common_widgets/input/custom_text_field.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:medibot/presentation/providers/auth/auth_provider.dart';
import 'package:medibot/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false; 

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      // Call the repository method to send reset email
      await authProvider.sendPasswordResetEmail(_emailController.text.trim());

      if (!mounted) return;

      // Mark email as sent - THIS SWITCHES TO SUCCESS UI
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          size: 28,
          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      body: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 30),
        alignment: Alignment.center,
        child: _emailSent ? _buildSuccessUI(theme, size) : _buildFormUI(theme, size),
      ),
    );
  }


  Widget _buildFormUI(ThemeData theme, Size size) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Enter you registered email below\n to receive password reset instruction',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.brightness == Brightness.dark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          SvgPicture.asset(
            'assets/images/forgotPassword.svg',
            height: size.height * 0.35,
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remember your Password?',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[900],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signIn);
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Send button
          _isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(
                  text: 'Send',
                  onPressed: _sendResetEmail,
                ),
        ],
      ),
    );
  }


  //succuss UI

  Widget _buildSuccessUI(ThemeData theme, Size size) {
    return Column(
      children: [
        Text(
          'Email has been sent!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Please check your inbox and click\nin the received link to reset a password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: theme.brightness == Brightness.dark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        SvgPicture.asset(
          'assets/images/forgotPassword.svg',
          height: size.height * 0.35,
          alignment: Alignment.topCenter,
          fit: BoxFit.fitWidth,
        ),
        
        const SizedBox(height: 32),
        
        // Login button
        PrimaryButton(
          text: 'Login',
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.signIn);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Didn't receive link? Resend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive the link?',
              style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[900],
              ),
            ),
            TextButton(
              onPressed: () {
                // Reset to form view to try again
                setState(() {
                  _emailSent = false;
                });
              },
              child: Text(
                'Resend',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}