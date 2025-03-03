import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0), // Отступы вокруг календаря
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          headerMargin:EdgeInsets.all(10),
          formatButtonVisible: false, // Скрыть кнопку переключения формата
          titleCentered: true, // Заголовок по центру
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Colors.deepPurple,
            size: 28,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Colors.deepPurple,
            size: 28,
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(
            color: Colors.deepPurple.withOpacity(0.7),
          ),
          outsideDaysVisible: false, // Скрыть дни из других месяцев
          defaultTextStyle: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: TextStyle(
            color: Colors.deepPurple.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        selectedDayPredicate: (day) => false, // Никакая дата не выбрана по умолчанию
        onDaySelected: (selectedDay, focusedDay) {
          // Обработка выбора даты
        },
        onFormatChanged: (format) {
          // Обработка изменения формата календаря
        },
        onPageChanged: (focusedDay) {
          // Обработка изменения страницы
        },
      ),
    );
  }
}