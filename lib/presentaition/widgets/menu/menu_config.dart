import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item_entity.dart';
import '../../../domain/entities/menu_section_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<dynamic>> getFilteredMenuItems() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final userDoc =
      await FirebaseFirestore.instance.collection('user').doc(uid).get();
  final data = userDoc.data();

  if (data == null) return [];

  final isAdmin = data['is_admin'] == true;
  final isManager = data['is_manager'] == true;

  final List<dynamic> all = [
    MenuSectionEntity(section: 'Управление задачами'),
    MenuItemEntity(icon: Icons.event, text: 'Задачи', page: 'home'),
    MenuItemEntity(icon: Icons.topic, text: 'Проекты', page: 'projects'),
    MenuItemEntity(icon: Icons.person, text: 'Сотрудники', page: 'employees'),
    MenuItemEntity(icon: Icons.groups, text: 'Отделы', page: 'departments'),
    MenuItemEntity(
      icon: Icons.analytics,
      text: 'Расчет зарплаты',
      page: 'perfomance',
    ),
  ];

  return all.where((item) {
    if (item is MenuSectionEntity) return true;

    final page = item.page;
    if (isAdmin) return true;
    if (isManager) return page != 'employees';
    return page == 'home' || page == 'perfomance';
  }).toList();
}
