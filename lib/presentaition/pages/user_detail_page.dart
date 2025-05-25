import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userRef = FirebaseFirestore.instance.collection('user').doc(userId);

    return StreamBuilder<DocumentSnapshot>(
      stream: userRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        if (!snapshot.data!.exists) {
          return Center(
            child: Text(
              'Пользователь не найден',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final fullname = data['fullname'] ?? '';
        final email = data['email'] ?? '';
        final isAdmin = data['is_admin'] ?? false;
        final isManager = data['is_manager'] ?? false;
        final salaryPerHour = data['salary_per_hour'] ?? 0.0;
        final salaryPerMonth = data['salary_per_month'] ?? 0.0;
        final departmentRef = data['department'] as DocumentReference?;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed:
                          () => GoRouter.of(context).goNamed('employees'),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      tooltip: 'Назад',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullname,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isAdmin)
                        Chip(
                          label: Text(
                            'Админ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.2),
                        ),
                      if (isManager && !isAdmin)
                        Chip(
                          label: Text(
                            'Менеджер',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(email, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  FutureBuilder<DocumentSnapshot>(
                    future: departmentRef?.get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          'Отдел: —',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }
                      final departmentName =
                          snapshot.data?.exists == true
                              ? snapshot.data!['name']
                              : '—';
                      return Text(
                        'Отдел: $departmentName',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ставка в час: ${salaryPerHour.toStringAsFixed(0)} ₽',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Оклад в месяц: ${salaryPerMonth.toStringAsFixed(0)} ₽',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Редактировать'),
                        onPressed: () {
                          _showEditDialog(context, userRef, data);
                        },
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Удалить'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text(
                                    'Удалить пользователя?',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                  content: Text(
                                    'Это удалит данные из Firestore.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: Text(
                                        'Отмена',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        'Удалить',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await userRef.delete();
                            if (context.mounted) {
                              GoRouter.of(context).goNamed('employees');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Пользователь удалён',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    DocumentReference userRef,
    Map<String, dynamic> data,
  ) {
    final nameController = TextEditingController(text: data['fullname'] ?? '');
    final salaryHourController = TextEditingController(
      text: data['salary_per_hour']?.toString() ?? '',
    );
    final salaryMonthController = TextEditingController(
      text: data['salary_per_month']?.toString() ?? '',
    );
    bool isAdmin = data['is_admin'] ?? false;
    bool isManager = data['is_manager'] ?? false;
    DocumentReference? selectedDepartment = data['department'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Редактировать пользователя',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'ФИО'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: salaryHourController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ставка в час',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: salaryMonthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Оклад в месяц',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<QuerySnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('department')
                                .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                          final departments = snapshot.data!.docs;
                          return DropdownButtonFormField<DocumentReference>(
                            value: selectedDepartment,
                            decoration: const InputDecoration(
                              labelText: 'Отдел',
                            ),
                            items:
                                departments.map((doc) {
                                  return DropdownMenuItem(
                                    value: doc.reference,
                                    child: Text(
                                      doc['name'],
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList(),
                            onChanged:
                                (val) =>
                                    setState(() => selectedDepartment = val),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: Text(
                          'Менеджер',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: isManager,
                        onChanged:
                            (val) => setState(() => isManager = val ?? false),
                      ),
                      CheckboxListTile(
                        title: Text(
                          'Администратор',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: isAdmin,
                        onChanged:
                            (val) => setState(() => isAdmin = val ?? false),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Отмена',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await userRef.update({
                  'fullname': nameController.text.trim(),
                  'salary_per_hour':
                      double.tryParse(salaryHourController.text.trim()) ?? 0,
                  'salary_per_month':
                      double.tryParse(salaryMonthController.text.trim()) ?? 0,
                  'is_admin': isAdmin,
                  'is_manager': isManager,
                  'department': selectedDepartment,
                });
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Пользователь обновлён',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              },
              child: Text(
                'Сохранить',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}
