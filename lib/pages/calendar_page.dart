import 'package:collection/collection.dart';
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
                        dropdownColor: Theme.of(context).colorScheme.secondary,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Exo',
                        ),
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
                    holidayTextStyle: TextStyle(color: Colors.white),
                    holidayDecoration: BoxDecoration(
                      color: Color(0xFFEF9A9A), //Color(0xFFD04848),
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0xFFEF9A9A), width: 1.4),
                      ),
                      shape: BoxShape.circle,
                    ),
                    markersAutoAligned: false,
                    markersOffset: PositionedOffset(bottom: -5.0),
                    selectedTextStyle: TextStyle(
                        color: Color(0xFF5C6BC0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                    selectedDecoration:
                        BoxDecoration(color: Colors.transparent),
                    todayDecoration: BoxDecoration(
                        color: Color.fromARGB(70, 25, 76, 37),
                        shape: BoxShape.circle),
                  ),
                  rowHeight: 90.0,
                  calendarBuilders: CalendarBuilders(
                    singleMarkerBuilder: (context, day, event) {
                      var formattedEvent = _formattedEvent(event as String);
                      TextStyle? style = isSameDay(_selectedTime, day)
                          ? const TextStyle(
                              color: Color.fromARGB(255, 115, 115, 44),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            )
                          : null;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formattedEvent.$1,
                            style: style,
                          ),
                          Text(
                            formattedEvent.$2,
                            style: style,
                          ),
                        ],
                      );
                    },
                  ),
                  eventLoader: (day) {
                    List<String> events = [];
                    if (workingEvent.eventMap.isNotEmpty) {
                      List<(String, String)>? workings =
                          workingEvent.eventMap[day]?.toList();
                      if (workings != null && workings.isNotEmpty) {
                        workings.removeWhere((e) =>
                            e.$1 != _focusedEmployee || _isHoliday(e.$2));
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
                        if (_isHoliday(workings.first.$2)) {
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
                          () {
                            List<(String, String)> sameDayWorkings =
                                workingEvent.eventMap[_selectedTime] ?? [];
                            _selectedEventNotifier.value = sameDayWorkings;
                            _showSameDayWorkings(sameDayWorkings.toList());
                          },
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
                      _calendarAppBloc.add(CalendarMonthChanged(
                          _focusedTime.year, _focusedTime.month));
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

  bool _isHoliday(String working) =>
      working.contains('休') || working.contains('例');

  (String, String) _formattedEvent(String event) {
    String location = event;
    String time = '';
    int indexLoc = event.indexOf(')');
    if (indexLoc >= 0) {
      location = event.substring(0, indexLoc + 1);
      time = event.substring(indexLoc + 1);
    }
    return (location, time);
  }

  void _showSameDayWorkings(List<(String, String)> sameDayWorkings) {
    final focusedEmployeeEvent = sameDayWorkings
        .firstWhereOrNull((events) => events.$1 == _focusedEmployee);
    if (focusedEmployeeEvent != null) {
      if (!_isHoliday(focusedEmployeeEvent.$2)) {
        final formattedEvent = _formattedEvent(focusedEmployeeEvent.$2);
        String location = formattedEvent.$1;
        String time = formattedEvent.$2;
        sameDayWorkings.retainWhere((events) {
          return events.$1 != _focusedEmployee &&
              _formattedEvent(events.$2).$1 == location;
        });
        if (sameDayWorkings.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return ListView.builder(
                itemCount: sameDayWorkings.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Column(
                      children: [
                        SizedBox(height: 8.0),
                        Text(
                          '其他員工',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8.0),
                        Divider(),
                      ],
                    );
                  }
                  return ListTile(
                    title: Text(sameDayWorkings[index - 1].$1),
                    subtitle: Text(sameDayWorkings[index - 1].$2),
                  );
                },
              );
            },
          );
        }
      }
    }
  }
}
