import 'package:flutter/material.dart';

class SideMenuSection extends StatelessWidget {
  final String section;

  const SideMenuSection({Key? key, required this.section}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ), // Отступы
      child: Text(
        section.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ), // Используем стиль из темы
      ),
    );
  }
}
