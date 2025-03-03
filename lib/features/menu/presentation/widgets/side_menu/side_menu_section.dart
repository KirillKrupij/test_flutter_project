import 'package:flutter/material.dart';

import '../../../../../app/app_styles.dart';

class SideMenuSection extends StatelessWidget {
  final String section;

  const SideMenuSection({Key? key, required this.section}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyles.sideMenuSectionPadding, // Отступы
      child: Text(
        section.toUpperCase(),
        style: AppStyles.sideMenuSectionTextStyle, // Используем стиль из app_styles.dart
      ),
    );
  }
}