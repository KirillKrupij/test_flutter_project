import 'package:flutter/material.dart';


class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(patient.name),
            subtitle: Text('Возраст: ${patient.age}, Диагноз: ${patient.diagnosis}'),
            onTap: () {
              // Действие при нажатии на пациента
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Выбран пациент: ${patient.name}')),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Действие при нажатии на кнопку добавления
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Добавить нового пациента')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Моковые данные для пациентов
final List<Patient> patients = [
  Patient(name: 'Иван Иванов', age: 35, diagnosis: 'Гипертония'),
  Patient(name: 'Мария Петрова', age: 28, diagnosis: 'Диабет'),
  Patient(name: 'Алексей Сидоров', age: 42, diagnosis: 'Астма'),
];

class Patient {
  final String name;
  final int age;
  final String diagnosis;

  Patient({required this.name, required this.age, required this.diagnosis});
}