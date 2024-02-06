import 'dart:async';
import 'dart:io';

import 'package:excel2calendar/bloc/calendar_bloc.dart';
import 'package:excel2calendar/bloc/calendarapp_bloc.dart';
import 'package:excel2calendar/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(BlocProvider(
    create: (context) => CalendarAppBloc(),
    child: const CalendarApp(),
  ));
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
    _sharingStub = ReceiveSharingIntent.getMediaStream().listen((medias) {
      print('$_logTag received media: ${medias.map((e) => e.path)}');
      if (medias.isNotEmpty) {
        _moveFileToAppDoc(medias[0].path);
      }
    });

    ReceiveSharingIntent.getInitialMedia().then((medias) {
      print('$_logTag get init media: ${medias.map((e) => e.path)}');
      if (medias.isNotEmpty) {
        _moveFileToAppDoc(medias[0].path);
      }
      ReceiveSharingIntent.reset();
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
          fileName = Uri.decodeComponent(fileName);
          srcFile.copy('${dstDir.path}/$fileName');
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(18, 55, 42, 1.0),
        ),
      ),
      home: BlocProvider(
        create: (context) => CalendarBloc(),
        child: const CalendarPage(),
      ),
    );
  }
}
