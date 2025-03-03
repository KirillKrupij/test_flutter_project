import 'package:flutter/material.dart';

import '../../../../../app/app_styles.dart'; 

class SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const SideMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppStyles.sideMenuItemHoverColor, // Цвет при наведении
      child: Padding(
        padding: AppStyles.sideMenuItemPadding, // Отступы
        child: Row(
          children: [
            Icon(
              icon,
              size: AppStyles.sideMenuItemIconSize, // Размер иконки
              color: AppStyles.sideMenuItemIconColor, // Цвет иконки
            ),
            const SizedBox(width: 16), // Отступ между иконкой и текстом
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge, // Используем стиль из темы
            ),
          ],
        ),
      ),
    );
  }
}