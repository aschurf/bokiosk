import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';
import 'dart:convert';
import 'dart:math';

import 'package:path_provider/path_provider.dart';


Future<void> sendIncident(String message, String description, String priority, String tag, Map details) async {
  //Создать инцидент для OpsGenie
  Map data = {
    'message': message,
    'description': description,
    'priority': priority,
    'details': details,
    'tags': [
      tag
    ],
    'impactedServices': [
      '79eb021b-db09-417a-ac1f-e5fccb1b4ed7'
    ],
    'responders': [
      {
        'id': 'fec8f160-7081-4402-85bc-8ad813bafd31',
        'type': 'team'
      }
    ]
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse('https://api.opsgenie.com/v1/incidents/create'),
      headers: {"Content-Type": "application/json", "Authorization": "GenieKey 2082716d-285b-477e-a98d-351e6bb212a9"},
      body: body);
}