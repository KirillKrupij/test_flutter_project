import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(event.title),
              subtitle: Text('Дата: ${event.date}, Место: ${event.location}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Действие при удалении события
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Событие удалено: ${event.title}')),
                  );
                },
              ),
              onTap: () {
                // Действие при нажатии на событие
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Выбрано событие: ${event.title}')),
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
            const SnackBar(content: Text('Добавить новое событие')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Моковые данные для событий
final List<Event> events = [
  Event(title: 'Конференция', date: '2023-10-10', location: 'Москва'),
  Event(title: 'Семинар', date: '2023-10-15', location: 'Санкт-Петербург'),
  Event(title: 'Встреча', date: '2023-10-20', location: 'Онлайн'),
];

class Event {
  final String title;
  final String date;
  final String location;

  Event({required this.title, required this.date, required this.location});
}