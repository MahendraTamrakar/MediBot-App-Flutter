import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final List<Widget> children;

  const SettingCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}
