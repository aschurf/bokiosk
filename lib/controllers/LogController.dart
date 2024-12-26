import 'dart:convert';
import 'dart:math';
import 'package:bokiosk/controllers/IikoController.dart';
import 'package:intl/intl.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants.dart';


Future<void> insertLog(String paymentGuid, String text) async {
  //ОПлата прошла успешно
  final conn = await MySQLConnection.createConnection(
    host: mySqlServer,
    port: 3306,
    userName: "kiosk_user",
    password: "Iehbr201010",
    databaseName: "kiosk", // optional
  );

  await conn.connect();

  await conn.execute('insert into payments_log (payment_guid, log_text) values (:payment_guid, :log_text)',
      {
        'payment_guid': paymentGuid,
        'log_text': text
      });

  await conn.close();
}

Future<void> logStashSend(String message, String orderNumber, String guid) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String version = packageInfo.version;

  //Получить апи токен
  Map data = {
    'source': 'kiosk',
    'version': version,
    'guid': guid,
    'message': message,
    'orderNumber': orderNumber,
    'kiosk': adressTitle
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse('http://95.163.228.219:8080'),
      headers: {"Content-Type": "application/json"},
      body: body);
}