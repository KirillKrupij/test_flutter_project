import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/features/app_bar/app_bar_title.dart';

class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  static ThemeModeNotifier of(BuildContext context) =>
      Provider.of<ThemeModeNotifier>(context, listen: false);
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  Future<DocumentSnapshot> _getCurrentUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    return FirebaseFirestore.instance.collection('user').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Consumer<AppBarTitleNotifier>(
        builder: (context, appBarTitleNotifier, _) {
          return Text(appBarTitleNotifier.title);
        },
      ),
      actions: [
        FutureBuilder<DocumentSnapshot>(
          future: _getCurrentUserDoc(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final fullname = data['fullname'] ?? '—';
            final isAdmin = data['is_admin'] == true;
            final isManager = data['is_manager'] == true;
            final role =
                isAdmin
                    ? 'Администратор'
                    : isManager
                    ? 'Менеджер'
                    : 'Сотрудник';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(fullname, style: const TextStyle(fontSize: 14)),
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    tooltip: 'Переключить тему',
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: () {
                      // Реализуй ThemeMode toggle в твоём app state
                      final mode =
                          Theme.of(context).brightness == Brightness.dark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                      // Например:
                      ThemeModeNotifier.of(context).setMode(mode);
                    },
                  ),
                  IconButton(
                    tooltip: 'Выйти',
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        GoRouter.of(context).go('/login');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
