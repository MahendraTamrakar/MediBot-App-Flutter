import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? textColor;
  final String? label;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.label,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    textColor ??
                    (theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color.fromARGB(154, 81, 103, 227)),
                size: 28,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  if (label != null)
                    SizedBox(
                      width: width*0.7,
                      child: Text(
                        label!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: FontWeight.w300
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
