import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String? _selectedDepartmentId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Все сотрудники',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'addUserBtn',
                    onPressed: () => GoRouter.of(context).goNamed('createUser'),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    tooltip: 'Добавить пользователя',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Фильтрация по отделу
              FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance.collection('department').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final departments = snapshot.data!.docs;
                  return Row(
                    children: [
                      Text(
                        'Фильтр по отделу:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _selectedDepartmentId,
                        hint: Text(
                          'Все отделы',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Все',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          ...departments.map((d) {
                            return DropdownMenuItem(
                              value: d.id,
                              child: Text(
                                d['name'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedDepartmentId = val;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Список пользователей
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('user').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Ошибка загрузки пользователей',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    final users =
                        snapshot.data!.docs.where((doc) {
                          if (_selectedDepartmentId == null) return true;
                          final department =
                              doc['department'] as DocumentReference?;
                          return department?.id == _selectedDepartmentId;
                        }).toList();

                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'Нет сотрудников в выбранном отделе',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final name = user['fullname'] ?? '';
                        final isAdmin = user['is_admin'] ?? false;
                        final isManager = user['is_manager'] ?? false;
                        final departmentRef =
                            user['department'] as DocumentReference?;

                        return FutureBuilder<DocumentSnapshot>(
                          future: departmentRef?.get(),
                          builder: (context, deptSnapshot) {
                            final departmentName =
                                deptSnapshot.data?.exists == true
                                    ? deptSnapshot.data!['name']
                                    : '—';

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  GoRouter.of(
                                    context,
                                  ).go('/employees/${user.id}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 32,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_roleLabel(isAdmin, isManager)} · $departmentName',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(bool isAdmin, bool isManager) {
    if (isAdmin) return 'Админ';
    if (isManager) return 'Менеджер';
    return 'Сотрудник';
  }
}
