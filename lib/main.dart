import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bokiosk/controllers/LogController.dart';
import 'package:dio/dio.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bokiosk/controllers/KkmServerController.dart';
import 'package:bokiosk/pages/AdminPage.dart';
import 'package:bokiosk/pages/HomePage.dart';
import 'package:bokiosk/pages/PinCodePage.dart';
import 'package:bokiosk/pages/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'constants.dart';
import 'models/ErrorNotifier.dart';
import 'opsgenie/opsgenieIncident.dart';


Future<Map> readConfig() async {
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return jsonDecode(contents);
  } catch (e) {
    // If encountering an error, return 0
    print(e.toString());
    throw Exception('Файл конфигурации не обнаружен');
  }
}

Future<String> get _localPath async {
  Directory tempDir = await getApplicationDocumentsDirectory();

  return tempDir.path;
}


Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/Kiosk/kioskConfig.json');
}

Future<File> get _logFile async {
  final path = await _localPath;
  return File('$path/Kiosk/kioskLog.txt');
}

Future<File> writeCounter(String message) async {
  final file = await _logFile;

  // Write the file
  return file.writeAsString(message, mode: FileMode.append);
}


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


  //Взять данные из файла конфигурации
  var res = await readConfig();
  if(res.containsKey('iikoOrganizationId')){
    iikoOrganizationId = res['iikoOrganizationId'];
  } else {
    writeCounter("В конфигурации не указан ID организации iikoOrganizationId");
    throw Exception("В конфигурации не указан ID организации iikoOrganizationId");
  }

  if(res.containsKey('iikoTerminalGroupId')){
    iikoTerminalGroupId = res['iikoTerminalGroupId'];
  } else {
    writeCounter("В конфигурации не указан ID терминала iikoTerminalGroupId");
    throw Exception("В конфигурации не указан ID терминала iikoTerminalGroupId");
  }

  if(res.containsKey('iikoTableOrderId')){
    iikoTableOrderId = res['iikoTableOrderId'];
  } else {
    writeCounter("В конфигурации не указан ID стола iikoTableOrderId");
    throw Exception("В конфигурации не указан ID стола iikoTableOrderId");
  }

  if(res.containsKey('iikoMenuId')){
    iikoMenuId = res['iikoMenuId'];
  } else {
    writeCounter("В конфигурации не указан ID меню iikoMenuId");
    throw Exception("В конфигурации не указан ID меню iikoMenuId");
  }

  if(res.containsKey('iikoMenuTakeAwayId')){
    iikoMenuTakeAwayId = res['iikoMenuTakeAwayId'];
  } else {
    writeCounter("В конфигурации не указан ID меню iikoMenuTakeAwayId");
    throw Exception("В конфигурации не указан ID меню iikoMenuTakeAwayId");
  }

  if(res.containsKey('iikoOrderTypeTakeAway')){
    iikoOrderTypeTakeAway = res['iikoOrderTypeTakeAway'];
  } else {
    writeCounter("В конфигурации не указан ID типа заказа iikoOrderTypeTakeAway");
    throw Exception("В конфигурации не указан ID типа заказа iikoOrderTypeTakeAway");
  }

  if(res.containsKey('iikoOrderTypeHere')){
    iikoOrderTypeHere = res['iikoOrderTypeHere'];
  } else {
    writeCounter("В конфигурации не указан ID типа заказа iikoOrderTypeHere");
    throw Exception("В конфигурации не указан ID типа заказа iikoOrderTypeHere");
  }

  if(res.containsKey('iikoPaymentTypeHere')){
    iikoPaymentTypeHere = res['iikoPaymentTypeHere'];
  } else {
    writeCounter("В конфигурации не указан ID типа оплаты iikoPaymentTypeHere");
    throw Exception("В конфигурации не указан ID типа оплаты iikoPaymentTypeHere");
  }

  if(res.containsKey('iikoPaymentTypeTakeAway')){
    iikoPaymentTypeTakeAway = res['iikoPaymentTypeTakeAway'];
  } else {
    writeCounter("В конфигурации не указан ID типа оплаты iikoPaymentTypeTakeAway");
    throw Exception("В конфигурации не указан ID типа оплаты iikoPaymentTypeTakeAway");
  }

  if(res.containsKey('iikoLocalAdress')){
    iikoLocalAdress = res['iikoLocalAdress'];
  } else {
    writeCounter("В конфигурации не указан адрес iikoLocalAdress");
    throw Exception("В конфигурации не указан адрес iikoLocalAdress");
  }


  if(res.containsKey('isIikoLocal')){
    isIikoLocal = res['isIikoLocal'];
  } else {
    writeCounter("В конфигурации не указан bool isIikoLocal");
    throw Exception("В конфигурации не указан bool isIikoLocal");
  }

  if(res.containsKey('isReadyForUpdate')){
    isReadyForUpdate = res['isReadyForUpdate'];
  } else {
    writeCounter("В конфигурации не указан bool isReadyForUpdate");
    throw Exception("В конфигурации не указан bool isReadyForUpdate");
  }

  if(res.containsKey('numDeviceKkm')){
    numDeviceKkm = res['numDeviceKkm'];
  } else {
    writeCounter("В конфигурации не указан порядковый номер ККТ numDeviceKkm");
    throw Exception("В конфигурации не указан порядковый номер ККТ numDeviceKkm");
  }

  if(res.containsKey('numDevicePrinter')){
    numDevicePrinter = res['numDevicePrinter'];
  } else {
    writeCounter("В конфигурации не указан порядковый номер принтера numDevicePrinter");
    throw Exception("В конфигурации не указан порядковый номер принтера numDevicePrinter");
  }

  if(res.containsKey('numDeviceEkvaring')){
    numDeviceEkvaring = res['numDeviceEkvaring'];
  } else {
    writeCounter("В конфигурации не указан порядковый номер эквайринга numDeviceEkvaring");
    throw Exception("В конфигурации не указан порядковый номер эквайринга numDeviceEkvaring");
  }

  if(res.containsKey('kkmServerUrl')){
    kkmServerUrl = res['kkmServerUrl'];
  } else {
    writeCounter("В конфигурации не указан адрес сервера ККМ kkmServerUrl");
    throw Exception("В конфигурации не указан адрес сервера КК kkmServerUrl");
  }

  if(res.containsKey('mySqlServer')){
    mySqlServer = res['mySqlServer'];
  } else {
    writeCounter("В конфигурации не указан адрес сервера MySQL mySqlServer");
    throw Exception("В конфигурации не указан адрес сервера MySQL mySqlServer");
  }

  if(res.containsKey('adressTitle')){
    adressTitle = res['adressTitle'];
  } else {
    writeCounter("В конфигурации не указан адрес киоска adressTitle");
    throw Exception("В конфигурации не указан адрес киоска adressTitle");
  }

  if(res.containsKey('deviceNumber')){
    deviceNumber = res['deviceNumber'];
  } else {
    writeCounter("В конфигурации не указан номер киоска deviceNumber");
    throw Exception("В конфигурации не указан номер киоска deviceNumber");
  }
  //
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorNotifier.instance.showError(details.exceptionAsString());
    logStashSend("FlutterError.onError ${details.exception} ${details.stack}", "", "");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logStashSend("PlatformDispatcher.instance.onError $error $stack", "", "");

    return true;
  };

  var kk = await GetDataKKT();
  var js = json.decode(kk);
  String code = "";
  if(js['Info']['SessionState'] == 2){
    final conn = await MySQLConnection.createConnection(
      host: mySqlServer,
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


  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    // Set packageName parameter to support MSIX.
    packageName: 'jecheck.ru.bokiosk',
  );

  await launchAtStartup.enable();
  logStashSend("Запуск киоска", "", "");
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
        home: ErrorOverlay(
          child: WelcomePage(),
        ),
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
        home: ErrorOverlay(
          child: AdminPage(),
        ),
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
        home: ErrorOverlay(
          child: WelcomePage(),
        ),
        builder: EasyLoading.init(),
      );
    }
  }
}
