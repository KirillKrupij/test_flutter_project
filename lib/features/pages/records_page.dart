import 'package:flutter/material.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.note),
              title: Text(record.title),
              subtitle: Text('Дата: ${record.date}, Пациент: ${record.patientName}'),
              onTap: () {
                // Действие при нажатии на запись
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Выбрана запись: ${record.title}')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Действие при нажатии на кнопку добавления
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Добавить новую запись')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Моковые данные для записей
final List<Record> records = [
  Record(title: 'Консультация', date: '2023-10-01', patientName: 'Иван Иванов'),
  Record(title: 'Анализы', date: '2023-10-02', patientName: 'Мария Петрова'),
  Record(title: 'Назначение лечения', date: '2023-10-03', patientName: 'Алексей Сидоров'),
];

class Record {
  final String title;
  final String date;
  final String patientName;

  Record({required this.title, required this.date, required this.patientName});
}