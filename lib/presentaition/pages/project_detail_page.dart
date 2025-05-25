import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final _nameController = TextEditingController();
  DocumentReference? _selectedManager;

  @override
  Widget build(BuildContext context) {
    final projectRef = FirebaseFirestore.instance
        .collection('project')
        .doc(widget.projectId);

    return StreamBuilder<DocumentSnapshot>(
      stream: projectRef.snapshots(),
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
              'Проект не найден',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final project = snapshot.data!;
        final data = project.data() as Map<String, dynamic>;
        final name = data['name'] ?? '';
        final managerRef = data['manager'] as DocumentReference?;
        _nameController.text = name;
        _selectedManager = managerRef;

        return FutureBuilder<DocumentSnapshot>(
          future: managerRef?.get(),
          builder: (context, managerSnap) {
            final managerName =
                managerSnap.hasData && managerSnap.data!.exists
                    ? managerSnap.data!['fullname'] ?? '—'
                    : '—';

            return FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('task')
                      .where('project', isEqualTo: projectRef)
                      .get(),
              builder: (context, taskSnap) {
                if (!taskSnap.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
                final tasks = taskSnap.data!.docs;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, name, managerName, projectRef),
                          const SizedBox(height: 24),
                          Text(
                            'Задачи в проекте:',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          tasks.isEmpty
                              ? Text(
                                'Задач нет',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                              : Expanded(
                                child: ListView.builder(
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = tasks[index];
                                    final taskData =
                                        task.data() as Map<String, dynamic>;
                                    final title = taskData['title'] ?? '—';
                                    final allocated =
                                        (taskData['allocated_time_sec'] ?? 0) /
                                        3600.0;
                                    final wasted =
                                        (taskData['wasted_time_sec'] ?? 0) /
                                        3600.0;

                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Выделено: ${allocated.toStringAsFixed(1)} ч',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                            Text(
                                              'Потрачено: ${wasted.toStringAsFixed(1)} ч',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
  }

  Widget _buildHeader(
    BuildContext context,
    String name,
    String managerName,
    DocumentReference projectRef,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => GoRouter.of(context).goNamed('projects'),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Руководитель: $managerName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.secondary,
              ),
              tooltip: 'Редактировать проект',
              onPressed: () => _showEditDialog(context, projectRef),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: 'Удалить проект',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: Text(
                          'Удалить проект?',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        content: Text(
                          'Это действие нельзя отменить.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              'Отмена',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              'Удалить',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  await projectRef.delete();
                  if (context.mounted) {
                    GoRouter.of(context).goNamed('projects');
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, DocumentReference ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Редактировать проект',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название проекта',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<QuerySnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('user')
                              .where('is_manager', isEqualTo: true)
                              .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                        final users = snapshot.data!.docs;
                        return DropdownButtonFormField<DocumentReference>(
                          value: _selectedManager,
                          decoration: const InputDecoration(
                            labelText: 'Руководитель',
                          ),
                          items:
                              users.map((doc) {
                                return DropdownMenuItem(
                                  value: doc.reference,
                                  child: Text(
                                    doc['fullname'],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                );
                              }).toList(),
                          onChanged:
                              (val) => setState(() {
                                _selectedManager = val;
                              }),
                        );
                      },
                    ),
                  ],
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
                await ref.update({
                  'name': _nameController.text.trim(),
                  'manager': _selectedManager,
                });
                if (context.mounted) Navigator.pop(context);
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
