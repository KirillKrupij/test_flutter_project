// сборка всех меню (нижнего и бокового)
import 'package:flutter/material.dart';

import 'package:test_app/features/menu/data/datasources/local_data_source.dart';
import 'package:test_app/presentaition/widgets/menu/bottom_nav_bar.dart';
import '../../../features/menu/data/repositories/menu_repository.dart';
import '../../../features/menu/domain/repositories/menu_repository.dart';
import 'side_menu/side_menu.dart';
import '../responsive_builder.dart';
import 'menu_config.dart';

Widget? getSideMenu(BuildContext context) {
  return ResponsiveBuilder.isDesktop(context) ||
          ResponsiveBuilder.isTablet(context)
      ? FutureBuilder<List<dynamic>>(
        future: getFilteredMenuItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          return MenuDrawer(menuItems: snapshot.data!);
        },
      )
      : null;
}

Widget? getNavBar(BuildContext context) {
  return ResponsiveBuilder.isMobile(context) ? BottomNavBar() : null;
}
