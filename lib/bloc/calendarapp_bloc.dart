import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

abstract class CalendarAppEvent {}

class CalendarReceiveFile extends CalendarAppEvent {}

class WorkingEvent {
  Map<String, List<String>> eventMap = {};
  WorkingEvent();
}

class CalendarAppBloc extends Bloc<CalendarAppEvent, WorkingEvent> {
  static const String source = 'source';
  final int _baseYear = 1911;

  CalendarAppBloc() : super(WorkingEvent()) {
    _loadFile();
  }

  void _loadFile() async {
    DateTime currentTime = DateTime.now();
    int tranditionalYear = currentTime.year - _baseYear;
    int month = currentTime.month;
    final appDoc = await getApplicationDocumentsDirectory();
    final sourceDir = Directory(p.join(appDoc.path, source));
    for(var file in sourceDir.listSync()) {
      final fileName = file.path.split('/').last;
      print('file name: $fileName');
    }
  }
}
