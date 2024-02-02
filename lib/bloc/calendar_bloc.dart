import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CalendarEvent {}

class CalendarMonthChanged extends CalendarEvent {}

class CalendarState {
  final int year;
  final int month;
  CalendarState(this.year, this.month);
}

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc()
      : super(CalendarState(DateTime.now().year, DateTime.now().month));
}
