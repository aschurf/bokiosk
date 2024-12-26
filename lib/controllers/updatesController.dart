import 'dart:convert';

import 'package:bokiosk/models/PaymentsModel.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<Map> checkUpdates() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  Map result = {};

  Map data = {
    'appVersion': version,
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse('https://new.procob.io/api/checkKioskVersion'),
      body: body);
  final respBody = json.decode(response.body);

  if(response.statusCode == 200){
    return respBody;
  } else {
    return result;
  }
}