import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medibot/presentation/navigation/auth_router.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallbackAction? onEditProfile;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 163, 163, 163),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child:
                  photoUrl != null && photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: photoUrl!,
                        fit: BoxFit.cover,

                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),

                        errorWidget:
                            (context, url, error) => const Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.white,
                            ),
                      )
                      : const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(email, style: theme.textTheme.bodySmall?.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
            style: ButtonStyle(
              //backgroundColor: WidgetStateProperty.all(theme.canvasColor),
              side: WidgetStateProperty.all(
                BorderSide(
                  color: const Color.fromARGB(255, 193, 193, 193),
                  width: 0.08,
                ),
              ),
            ),
            child: Text(
              'Edit profile',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
