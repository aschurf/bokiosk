import 'dart:convert';
import 'dart:math';
import 'package:bokiosk/controllers/IikoController.dart';
import 'package:intl/intl.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';

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