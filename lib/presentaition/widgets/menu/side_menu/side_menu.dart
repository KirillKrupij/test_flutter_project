import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'side_menu_item.dart';
import 'side_menu_section.dart';

import '../../../../domain/entities/menu_section_entity.dart';
import '../../../../domain/entities/menu_item_entity.dart';

class MenuDrawer extends StatelessWidget {
  final List<dynamic> menuItems;
  final Function(dynamic item)? onItemTap;

  const MenuDrawer({Key? key, required this.menuItems, this.onItemTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          if (item is MenuSectionEntity) {
            return SideMenuSection(section: item.section);
          } else if (item is MenuItemEntity) {
            return SideMenuItem(
              icon: item.icon,
              text: item.text,
              onTap: () {
                if (onItemTap != null) {
                  onItemTap!(item);
                } else {
                  GoRouter.of(context).goNamed(item.page);
                  Navigator.pop(context);
                }
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
