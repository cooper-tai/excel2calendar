import 'dart:async';
import 'dart:io';

import 'package:excel2calendar/bloc/calendarapp_bloc.dart';
import 'package:excel2calendar/pages/calendar_page.dart';
import 'package:excel2calendar/utils/sharedpreference_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesUtil.init();
  // unawaited(MobileAds.instance.initialize());
  initializeDateFormatting().then(
    (_) => runApp(BlocProvider(
      create: (context) => CalendarAppBloc(),
      child: const CalendarApp(),
    )),
  );
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  final String _logTag = '[CalendarApp]';
  late StreamSubscription _sharingStub;
  late CalendarAppBloc _calendarAppBloc;

  @override
  void initState() {
    super.initState();
    _calendarAppBloc = BlocProvider.of<CalendarAppBloc>(context);
    _sharingStub =
        ReceiveSharingIntent.instance.getMediaStream().listen((medias) {
      print('$_logTag received media: ${medias.map((e) => e.path)}');
      if (medias.isNotEmpty) {
        _moveFileToAppDoc(medias[0].path);
      }
    }, onError: (e) {
      print('$_logTag onError: $e');
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((medias) {
      print('$_logTag get init media: ${medias.map((e) => e.path)}');
      if (medias.isNotEmpty) {
        _moveFileToAppDoc(medias[0].path);
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sharingStub.cancel();
  }

  void _moveFileToAppDoc(String fromPath) async {
    print('_moveFileToAppDoc srcFile fromPath: $fromPath');
    if (Platform.isIOS) {
      final Directory appDocument = await getApplicationDocumentsDirectory();
      String dstFolderName = 'source';
      Directory dstDir = Directory(p.join(appDocument.path, dstFolderName));
      if (!dstDir.existsSync()) {
        dstDir.createSync();
      }
      final srcFile = File.fromUri(Uri.parse(fromPath));
      srcFile.exists().then((isExist) {
        if (isExist) {
          String fileName = fromPath.split('/').last;
          try {
            fileName = Uri.decodeComponent(fileName);
          } catch (e) {
            print('$_logTag uri decode error: $e');
          }
          srcFile.copy('${dstDir.path}/$fileName').then((newPath) {
            int yearIndex = fileName.indexOf('年');
            int monthIndex = fileName.indexOf('月');
            if (yearIndex < monthIndex) {
              int fileYear =
                  int.tryParse(fileName.substring(0, yearIndex)) ?? 0;
              int fileMonth =
                  int.tryParse(fileName.substring(yearIndex + 1, monthIndex)) ??
                      0;
              if (fileYear > 0 && fileMonth > 0) {
                _calendarAppBloc.add(CalendarMonthChanged(
                  fileYear + 1911,
                  fileMonth,
                  isForceUpdate: true,
                ));
              }
            } else {
              print('Failed to parse $fileName from 3rd shared');
            }
          });
        }
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(18, 55, 42, 1.0),
        ),
        fontFamily: 'Exo',
      ),
      home: const CalendarPage(),
    );
  }
}
