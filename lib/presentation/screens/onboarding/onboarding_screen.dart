import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';
import 'package:medibot/presentation/navigation/navigation_service.dart';
import 'package:medibot/presentation/screens/auth/sign_up/sign_up_screen.dart';
import 'package:medibot/presentation/screens/onboarding/widgets/slider_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnBoarding(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (context.mounted) {
      log('Sign up screen ...');
      Navigator.pushReplacementNamed(context, AppRoutes.signUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            height: size.height,
            child: SvgPicture.asset(
              'assets/images/onboarding/doctorOnboarding.svg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.35,
              margin: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(40),
                /* boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 216, 216, 216).withValues(),
                    blurRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ], */
              ),
              padding: EdgeInsets.all(21.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Your Virtual\nHealthcare ',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        TextSpan(
                          text: 'Chatbot',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Your Virtual Healthcare Assistant: Partner in wellness, just a message away.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 112, 112, 112),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SlideActionButton(
                      text: "Get Started",
                      onSubmit: () => _completeOnBoarding(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
