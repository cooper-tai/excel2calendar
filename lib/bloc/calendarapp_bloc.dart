import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

abstract class CalendarAppEvent {}

class CalendarReceiveFile extends CalendarAppEvent {}

class WorkingEvent {
  Map<DateTime, List<(String, String)>> eventMap = {};
  WorkingEvent();

  void toLog() {
    eventMap.forEach((key, value) {
      print('DateTime: $key');
      print('$value');
    });
  }
}

class CalendarAppBloc extends Bloc<CalendarAppEvent, WorkingEvent> {
  static const String source = 'source';
  final int _baseYear = 1911;
  Map<DateTime, WorkingEvent> _cachedEventMap = {};

  CalendarAppBloc() : super(WorkingEvent()) {
    _loadFile(DateTime.now());
  }

  void _loadFile(DateTime time, {bool isForceUpdate = false}) async {
    int tranditionalYear = time.year - _baseYear;
    int month = time.month;
    WorkingEvent? cachedEvents =
        _cachedEventMap[DateTime(time.year, time.month)];
    if (cachedEvents != null && !isForceUpdate) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(cachedEvents);
      return;
    }
    final appDoc = await getApplicationDocumentsDirectory();
    final sourceDir = Directory(p.join(appDoc.path, source));
    FileSystemEntity? foundFile = sourceDir.listSync().firstWhereOrNull((file) {
      final fileName = file.path.split('/').last;
      int yearIndex = fileName.indexOf('年');
      int monthIndex = fileName.indexOf('月');
      if (yearIndex < monthIndex) {
        String fileYear = fileName.substring(0, yearIndex);
        String fileMonth = fileName.substring(yearIndex + 1, monthIndex);
        if ((int.tryParse(fileYear) ?? 0) == tranditionalYear &&
            (int.tryParse(fileMonth) ?? 0) == month) {
          print('Matched file $fileName');
          return true;
        }
      } else {
        print('Failed to parse $fileName');
      }
      return false;
    });
    if (foundFile != null && foundFile is File) {
      // try to parse content
      _parseContent(foundFile, time.year, time.month);
    }
  }

  void _parseContent(File file, int year, int month) async {
    print('parse content from ${file.path}');
    var bytes = file.readAsBytesSync();
    var excel = SpreadsheetDecoder.decodeBytes(bytes);
    String tableName = '班表';
    print(excel.tables.keys);
    WorkingEvent resultEvents = WorkingEvent();
    if (excel.tables.containsKey(tableName)) {
      var sheet = excel.tables[tableName];
      List<(int, int)> indexedDays = [];
      for (List<dynamic> row in (sheet?.rows ?? [])) {
        if (row.isNotEmpty) {
          // case of indexed days
          if (row[0] == 'V2') {
            row.forEachIndexed((index, data) {
              if (data != null) {
                int? days = int.tryParse(data.toString());
                if (days != null) {
                  indexedDays.add((index, days));
                }
              }
            });
          }

          // case of employee ID
          if (row[0] != null && row[0] is String && row[0].contains('ZA')) {
            String employeeID =
                row[0].toString().replaceAll(RegExp(r'\s+\b|\b\s'), '');
            for (var indexD in indexedDays) {
              int index = indexD.$1;
              int days = indexD.$2;
              DateTime anchor = DateTime(year, month, days);
              if (resultEvents.eventMap.containsKey(anchor)) {
                resultEvents.eventMap[anchor]!.add((
                  employeeID,
                  row[index].toString().replaceAll(RegExp(r'\s+\b|\b\s'), '')
                ));
              } else {
                resultEvents.eventMap[anchor] = [
                  (
                    employeeID,
                    row[index].toString().replaceAll(RegExp(r'\s+\b|\b\s'), '')
                  )
                ];
              }
            }
          }
        }
      }
      // ignore: invalid_use_of_visible_for_testing_member
      emit(resultEvents);
      _cachedEventMap[DateTime(year, month)] = resultEvents;
    }
  }
}
