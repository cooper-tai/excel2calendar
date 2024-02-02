import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<CalendarPage> {
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: TableCalendar(
        focusedDay: _currentTime,
        firstDay: DateTime(_currentTime.year - 3),
        lastDay: DateTime(_currentTime.year + 10, 12, 31),
        availableCalendarFormats: const {CalendarFormat.month: 'month'},
      ),
    );
  }
}
