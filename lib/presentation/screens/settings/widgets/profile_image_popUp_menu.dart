import 'package:flutter/material.dart';

class ProfileImagePopupMenu extends StatefulWidget {
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  const ProfileImagePopupMenu({
    super.key,
    required this.onGallery,
    required this.onRemove,
  });

  @override
  State<ProfileImagePopupMenu> createState() => _ProfileImagePopupMenuState();
}

class _ProfileImagePopupMenuState extends State<ProfileImagePopupMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.camera_enhance_rounded, size: 21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: theme.cardColor,
        offset: const Offset(60, 42),
        itemBuilder: (itemContext) {
          final itemTheme = Theme.of(itemContext);
          return [
            PopupMenuItem<String>(
              value: 'gallery',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20, color: itemTheme.iconTheme.color),
                  const SizedBox(width: 10),
                  Text(
                    'Choose from gallery',
                    style: itemTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'remove',
              child: Row(
                children: [
                  const Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                  const SizedBox(width: 10),
                  Text(
                    'Remove',
                    style: itemTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 'gallery') {
            widget.onGallery();
          } else if (value == 'remove') {
            widget.onRemove();
          }
        },
      ),
    );
  }
}
