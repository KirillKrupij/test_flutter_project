import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Проекты',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'addProjectBtn',
                    onPressed:
                        () => GoRouter.of(context).goNamed('createProject'),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    tooltip: 'Создать проект',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Список проектов
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('project')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    final projects = snapshot.data!.docs;

                    if (projects.isEmpty) {
                      return Center(
                        child: Text(
                          'Проектов пока нет',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        final projectId = project.id;
                        final name = project['name'] ?? '';
                        final managerRef =
                            project['manager'] as DocumentReference?;

                        return FutureBuilder<DocumentSnapshot>(
                          future: managerRef?.get(),
                          builder: (context, managerSnapshot) {
                            final managerName =
                                managerSnapshot.hasData &&
                                        managerSnapshot.data!.exists
                                    ? managerSnapshot.data!['fullname'] ?? '—'
                                    : '—';

                            return FutureBuilder<QuerySnapshot>(
                              future:
                                  FirebaseFirestore.instance
                                      .collection('task')
                                      .where(
                                        'project',
                                        isEqualTo: project.reference,
                                      )
                                      .get(),
                              builder: (context, taskSnapshot) {
                                final taskCount =
                                    taskSnapshot.hasData
                                        ? taskSnapshot.data!.size
                                        : 0;

                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  elevation: 2,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap:
                                        () => GoRouter.of(
                                          context,
                                        ).go('/project/$projectId'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.work_outline,
                                            size: 32,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).iconTheme.color,
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
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Руководитель: $managerName',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Задач в проекте: $taskCount',
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).iconTheme.color,
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
