import 'dart:convert';
import 'dart:io';

import 'package:bokiosk/controllers/KkmServerController.dart';
import 'package:bokiosk/pages/AdminPage.dart';
import 'package:bokiosk/pages/HomePage.dart';
import 'package:bokiosk/pages/PinCodePage.dart';
import 'package:bokiosk/pages/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:window_manager/window_manager.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setFullScreen(true);
  });

  HttpOverrides.global = MyHttpOverrides();

  var kk = await GetDataKKT();
  var js = json.decode(kk);
  String code = "";
  if(js['Info']['SessionState'] == 2){
    final conn = await MySQLConnection.createConnection(
      host: "192.168.0.153",
      port: 3306,
      userName: "kiosk_user",
      password: "Iehbr201010",
      databaseName: "kiosk", // optional
    );

    await conn.connect();

    var result = await conn.execute('SELECT * FROM shifts WHERE session_number = :sNumber',
        {
          'sNumber': js['SessionNumber'],
        });


    print(result.numOfRows);

    for (final re in result.rows) {
      print('MySQL result');
      code = re.colByName("shift_code")!;
    }

    await conn.close();
  }

  runApp(MyApp(kktData: kk, code: code, kkmState: js,));
}

class MyApp extends StatelessWidget {
  String kktData;
  String code;
  Map<String, dynamic> kkmState;
  MyApp({super.key, required this.kktData, required this.code, required this.kkmState});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var js = json.decode(kktData);
    if(js['Info']['SessionState'] == 2){
      return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: WelcomePage(),
        builder: EasyLoading.init(),
      );
    } else if(js['Info']['SessionState'] == 1){
      return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AdminPage(),
        builder: EasyLoading.init(),
      );
    } else {
      return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: WelcomePage(),
        builder: EasyLoading.init(),
      );
    }
  }
}
