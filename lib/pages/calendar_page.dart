import 'package:excel2calendar/bloc/calendarapp_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<CalendarPage> {
  late DateTime _focusedTime;
  late DateTime _selectedTime;
  late CalendarAppBloc _calendarAppBloc;
  late String _focusedEmployee;
  late ValueNotifier<List<(String, String)>> _selectedEventNotifier;

  @override
  void initState() {
    super.initState();
    _focusedTime = DateTime.now();
    _selectedTime = _focusedTime;
    _calendarAppBloc = BlocProvider.of<CalendarAppBloc>(context);
    _focusedEmployee = '';
    _selectedEventNotifier = ValueNotifier([]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarAppBloc, WorkingEvent>(
      bloc: _calendarAppBloc,
      builder: (context, workingEvent) {
        if (workingEvent.employeeIDs.isEmpty) {
          _focusedEmployee = '';
        }
        if (workingEvent.employeeIDs.isNotEmpty && _focusedEmployee.isEmpty) {
          _focusedEmployee = workingEvent.employeeIDs[0];
        }
        return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: workingEvent.employeeIDs.isEmpty
                  ? const Text('Calendar')
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        iconEnabledColor: Colors.white70,
                        items: workingEvent.employeeIDs
                            .map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        value: _focusedEmployee,
                        onChanged: (value) => setState(() {
                          _focusedEmployee = value ?? '';
                          if (workingEvent.eventMap.isNotEmpty) {
                            _selectedEventNotifier.value =
                                workingEvent.eventMap[_selectedTime] ?? [];
                          }
                        }),
                      ),
                    ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            body: Column(
              children: [
                TableCalendar(
                  focusedDay: _focusedTime,
                  currentDay: DateTime.now(),
                  firstDay: DateTime(_focusedTime.year - 3),
                  lastDay: DateTime(_focusedTime.year + 10, 12, 31),
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'month'
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    holidayTextStyle:
                        TextStyle(color: Colors.white),
                    holidayDecoration: BoxDecoration(
                      color: Color(0xFFEF9A9A),//Color(0xFFD04848),
                      border: Border.fromBorderSide(
                        BorderSide(
                            color: Color(0xFFEF9A9A), width: 1.4),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    List<String> events = [];
                    if (workingEvent.eventMap.isNotEmpty) {
                      List<(String, String)>? workings =
                          workingEvent.eventMap[day]?.toList();
                      if (workings != null && workings.isNotEmpty) {
                        workings.removeWhere((e) =>
                            e.$1 != _focusedEmployee ||
                            (e.$2.contains('休') || e.$2.contains('例')));
                        events.addAll(workings.map((e) => e.$2).toList());
                      }
                    }
                    return events;
                  },
                  holidayPredicate: (day) {
                    bool isHoliday = false;
                    if (workingEvent.eventMap.isNotEmpty) {
                      List<(String, String)>? workings =
                          workingEvent.eventMap[day]?.toList();
                      if (workings != null && workings.isNotEmpty) {
                        workings.removeWhere((e) => e.$1 != _focusedEmployee);
                        // should only one left
                        if (workings.first.$2.contains('休') ||
                            workings.first.$2.contains('例')) {
                          isHoliday = true;
                        }
                      }
                    }
                    return isHoliday;
                  },
                  selectedDayPredicate: (day) {
                    if (isSameDay(_selectedTime, day)) {
                      if (workingEvent.eventMap[_selectedTime]?.isNotEmpty ??
                          false) {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _selectedEventNotifier.value =
                              workingEvent.eventMap[_selectedTime] ?? [],
                        );
                      }
                      return true;
                    }
                    return false;
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedTime = selectedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedTime = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _selectedEventNotifier,
                    builder: (context, events, child) {
                      List<(String, String)> focusedEmployEvents = events
                          .toList()
                        ..removeWhere((e) => e.$1 != _focusedEmployee);
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        itemCount: focusedEmployEvents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 2.0,
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            title: Text(focusedEmployEvents[index].$2),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ));
      },
    );
  }
}
