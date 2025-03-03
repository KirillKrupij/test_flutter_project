// сборка всех меню (нижнего и бокового)
import 'package:flutter/material.dart';

import 'package:test_app/features/menu/data/datasources/local_data_source.dart';
import 'package:test_app/features/menu/presentation/widgets/bottom_nav_bar.dart';
import '../data/repositories/menu_repository.dart';
import '../domain/repositories/menu_repository.dart';
import 'widgets/side_menu/side_menu.dart';
import 'widgets/responsive_builder.dart';




class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenu createState() => _SideMenu();
}

class _SideMenu extends State<SideMenu> {
  List<dynamic> menuItems = [];

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    MenuDomainRepository menuDomainRepository = MenuDomainRepository(
      menuRepository: MenuDataRepository(
        menuLocalDataSource:MenuLocalDataSource(
          serverUrl: 'http://localhost:8000/menu.php',
          localPath: 'assets/json/menu.json'
        )
      )
    );
    final menuItemsNew = await menuDomainRepository.getMenuEntities();
    setState(() {
      menuItems = menuItemsNew;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuDrawer(menuItems: menuItems);
  }
}

Widget? getSideMenu(BuildContext context) {
  return ResponsiveBuilder.isDesktop(context) || ResponsiveBuilder.isTablet(context) ? SideMenu() : null;
}


Widget? getNavBar(BuildContext context) {
  return ResponsiveBuilder.isMobile(context)  ? BottomNavBar() : null;
}

