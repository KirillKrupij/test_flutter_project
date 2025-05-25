import 'package:flutter/material.dart';

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
      hoverColor: Theme.of(context).hoverColor, // Цвет при наведении
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ), // Отступы
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.0, // Размер иконки
              color: Theme.of(context).iconTheme.color, // Цвет иконки
            ),
            const SizedBox(width: 16), // Отступ между иконкой и текстом
            Text(
              text,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodyLarge, // Используем стиль из темы
            ),
          ],
        ),
      ),
    );
  }
}
