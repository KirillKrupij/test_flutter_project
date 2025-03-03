//класс для построения структуры документа в зависимости от ширины экрана
import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget fallback; // Заглушка для случаев, когда параметр == null

  const ResponsiveBuilder({
    Key? key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.fallback = const SizedBox.shrink(), // По умолчанию пустой виджет
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile ?? fallback; // Используем fallback, если mobile == null
        } else if (constraints.maxWidth < 1200) {
          return tablet ?? fallback; // Используем fallback, если tablet == null
        } else {
          return desktop ?? fallback; // Используем fallback, если desktop == null
        }
      },
    );
  }
}