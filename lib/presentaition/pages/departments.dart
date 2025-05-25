import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DepartmentListPage extends StatelessWidget {
  const DepartmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
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
                    'Отделы',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'addDeptBtn',
                    onPressed:
                        () => GoRouter.of(context).goNamed('createDepartment'),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    tooltip: 'Добавить отдел',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Список отделов
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('department')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    final departments = snapshot.data!.docs;

                    if (departments.isEmpty) {
                      return Center(
                        child: Text(
                          'Отделов пока нет',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: departments.length,
                      itemBuilder: (context, index) {
                        final dept = departments[index];
                        final name = dept['name'] ?? '';
                        final supervisorRef =
                            dept['supervisor'] as DocumentReference?;

                        return FutureBuilder<DocumentSnapshot>(
                          future: supervisorRef?.get(),
                          builder: (context, snapshot) {
                            final supervisorName =
                                snapshot.hasData && snapshot.data!.exists
                                    ? snapshot.data!['fullname']
                                    : '—';

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  GoRouter.of(
                                    context,
                                  ).go('/department/${dept.id}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.apartment,
                                        size: 32,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Руководитель: $supervisorName',
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
}
