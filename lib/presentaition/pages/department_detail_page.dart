import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphview/GraphView.dart';

class DepartmentDetailPage extends StatefulWidget {
  final String departmentId;
  const DepartmentDetailPage({super.key, required this.departmentId});

  @override
  State<DepartmentDetailPage> createState() => _DepartmentDetailPageState();
}

class _DepartmentDetailPageState extends State<DepartmentDetailPage> {
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  Node? root;
  double totalSalary = 0.0;

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = (20)
      ..levelSeparation = (40)
      ..subtreeSeparation = (30)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  @override
  Widget build(BuildContext context) {
    final departmentRef = FirebaseFirestore.instance
        .collection('department')
        .doc(widget.departmentId);

    return StreamBuilder<DocumentSnapshot>(
      stream: departmentRef.snapshots(),
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
              'Отдел не найден',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? '';
        final supervisorRef = data['supervisor'] as DocumentReference?;

        return FutureBuilder<DocumentSnapshot>(
          future: supervisorRef?.get(),
          builder: (context, supervisorSnapshot) {
            final supervisorData =
                supervisorSnapshot.data?.data() as Map<String, dynamic>?;
            final supervisorName = supervisorData?['fullname'] ?? '—';
            final supervisorId = supervisorSnapshot.data?.id;

            return FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('user')
                      .where('department', isEqualTo: departmentRef)
                      .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
                final users = userSnapshot.data!.docs;

                totalSalary = 0.0;
                graph.nodes.clear();
                graph.edges.clear();

                root = Node.Id(supervisorName);
                graph.addNode(root!);

                for (final user in users) {
                  final id = user.id;
                  final name = user['fullname'];
                  final salary = (user['salary_per_month'] ?? 0.0) as num;
                  totalSalary += salary;

                  if (id != supervisorId) {
                    final empNode = Node.Id(name);
                    graph.addNode(empNode);
                    graph.addEdge(root!, empNode);
                  }
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed:
                                () =>
                                    GoRouter.of(context).goNamed('departments'),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            tooltip: 'Назад',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Оклад: ${totalSalary.toStringAsFixed(0)} ₽ / мес',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                        tooltip: 'Редактировать отдел',
                                        onPressed: () {
                                          _showEditDialog(
                                            context,
                                            departmentRef,
                                            name,
                                            supervisorRef,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                        tooltip: 'Удалить отдел',
                                        onPressed: () async {
                                          final confirm = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (ctx) => AlertDialog(
                                                  title: Text(
                                                    'Удалить отдел?',
                                                    style:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall,
                                                  ),
                                                  content: Text(
                                                    'Это действие удалит отдел без восстановления.',
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: Text(
                                                        'Отмена',
                                                        style:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: Text(
                                                        'Удалить',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .error,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                          if (confirm == true) {
                                            await departmentRef.delete();
                                            if (context.mounted) {
                                              GoRouter.of(
                                                context,
                                              ).goNamed('departmentList');
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Отдел удалён',
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
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
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Структура отдела:',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: InteractiveViewer(
                              boundaryMargin: const EdgeInsets.all(100),
                              constrained: false,
                              minScale: 0.01,
                              maxScale: 5.0,
                              child: GraphView(
                                graph: graph,
                                algorithm: BuchheimWalkerAlgorithm(
                                  builder,
                                  TreeEdgeRenderer(builder),
                                ),
                                builder: (node) {
                                  final label = node.key!.value as String;
                                  final isBoss = label == supervisorName;
                                  return _graphNodeWidget(label, isBoss);
                                },
                              ),
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

  Widget _graphNodeWidget(String label, bool isBoss) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isBoss
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Theme.of(context).shadowColor.withOpacity(0.2),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    DocumentReference deptRef,
    String currentName,
    DocumentReference? currentSupervisor,
  ) {
    final nameController = TextEditingController(text: currentName);
    DocumentReference? selectedSupervisor = currentSupervisor;
    final Set<DocumentReference> selectedEmployees = {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Редактировать отдел',
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название отдела',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<QuerySnapshot>(
                      future:
                          FirebaseFirestore.instance.collection('user').get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                        final users = snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<DocumentReference>(
                              value: selectedSupervisor,
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
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => selectedSupervisor = val),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Добавить сотрудников:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            ...users.map((doc) {
                              final ref = doc.reference;
                              final name = doc['fullname'];
                              return CheckboxListTile(
                                title: Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: selectedEmployees.contains(ref),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedEmployees.add(ref);
                                    } else {
                                      selectedEmployees.remove(ref);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ],
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
                await deptRef.update({
                  'name': nameController.text.trim(),
                  'supervisor': selectedSupervisor,
                });
                for (final userRef in selectedEmployees) {
                  await userRef.update({'department': deptRef});
                }
                if (context.mounted) {
                  GoRouter.of(context).goNamed('departments');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Отдел обновлён',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
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
