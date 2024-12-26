import 'dart:convert';

import 'package:bokiosk/models/PaymentsModel.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';

import 'package:bokiosk/pages/HistoryPayments.dart';

import '../constants.dart';
import 'KkmServerController.dart';


Future<String> returnPayByCheckNumber(int checkNumber) async {
  final conn = await MySQLConnection.createConnection(
    host: mySqlServer,
    port: 3306,
    userName: "kiosk_user",
    password: "Iehbr201010",
    databaseName: "kiosk", // optional
  );

  await conn.connect();

  var result = await conn.execute('SELECT * FROM payments WHERE check_number = :check_number',
      {
        'check_number': checkNumber,
      });

  int statusOfPayment = 0;
  String paymentGuid = "";
  String universalId = "";

  for (final re in result.rows) {
    print(re.assoc());
    statusOfPayment = int.parse(re.colByName("status")!);
    paymentGuid = re.colByName("guid")!;
    universalId = re.colByName("univId")!;
  }

  await conn.close();


  if(statusOfPayment == 1){
    final conn = await MySQLConnection.createConnection(
      host: mySqlServer,
      port: 3306,
      userName: "kiosk_user",
      password: "Iehbr201010",
      databaseName: "kiosk", // optional
    );

    await conn.connect();

    var resultDishes = await conn.execute('SELECT * FROM payments_dishes WHERE payment_guid = :payment_guid',
        {
          'payment_guid': paymentGuid,
        });

    num sumOrd = 0;
    List<Map> strings = [];
    List<Map> checkInfo = [];
    checkInfo.add({
      "PrintText": {
        "Text": ">#2#<ООО \"БУНБОНАМБО\"",
        "Font": 1,
      }
    });

    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": ">#2#<Возврат прихода",
        "Font": 2,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "",
      }
    });


    for (final dish in resultDishes.rows) {
      num dishPrice = num.parse(dish.colByName("dish_price")!);
      int dishCount = int.parse(dish.colByName("dish_count")!);
      checkInfo.add({
        "PrintText": {
          "Text": dish.colByName("dish_count")! + " " + dish.colByName("dish_name")! + "<#0#>" + dish.colByName("dish_price")! + ".00 * " + dish.colByName("dish_count")! + " шт. = " + (dishCount * dishPrice).toString() + ".00",
          "Font": 3,
        }
      });
      //Регистрация чека в ОФД
      strings.add({
        "Register": {
          "Name": dish.colByName("dish_name")!,
          "Quantity": dishCount,
          "Price": dishPrice,
          "Amount": dishPrice * dishCount,
          "Department": 1,
          "Tax": -1,
          "SignMethodCalculation": 4,
          "SignCalculationObject": 1,
          "MeasureOfQuantity": 0,
        }
      });
      sumOrd += dishPrice * dishCount;
    }

    await conn.close();

    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "ИТОГ <#0#>=" + sumOrd.toString() + ".00",
        "Font": 1,
        "Intensity": 1,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "СУММА БЕЗ НДС <#0#>=" + sumOrd.toString() + ".00",
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "БЕЗНАЛИЧНЫМИ <#0#>=" + sumOrd.toString() + ".00",
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НОМЕР УСТРОЙСТВА <#20#>$deviceNumber",
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "ООО \"БУНБОНАМБО\"",
        "Font": 3,
        "Intensity": 15,
      }
    });

    checkInfo.add({
      "PrintText": {
        "Text": adressTitle,
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Место расчетов <#0#>$adressTitle",
        "Font": 3,
      }
    });


    await returnPayment(strings, checkInfo, sumOrd, universalId).then((res) async {
      final conn = await MySQLConnection.createConnection(
        host: mySqlServer,
        port: 3306,
        userName: "kiosk_user",
        password: "Iehbr201010",
        databaseName: "kiosk", // optional
      );

      await conn.connect();

      await conn.execute('UPDATE payments SET status = 2 WHERE guid = :guid',
          {
            'guid': paymentGuid,
          });
      await conn.close();

      return "OK";
    }).catchError((error){
      throw(error);
    });

    return "OK";
  } else {
    throw("Заказ уже был врзвращен!");
  }
}

Future<List<PaymentsModel>> getPayments() async {

  List<PaymentsModel> payments = [];

  var kkt = await GetDataKKT();
  var js = json.decode(kkt);

  if(js['Info']['SessionState'] == 2){
    final conn = await MySQLConnection.createConnection(
      host: mySqlServer,
      port: 3306,
      userName: "kiosk_user",
      password: "Iehbr201010",
      databaseName: "kiosk", // optional
    );

    await conn.connect();

    var result = await conn.execute('SELECT * FROM payments WHERE session_number = :session_number',
        {
          'session_number': js['SessionNumber'],
        });

    for (final re in result.rows) {
      payments.add(PaymentsModel(
          guid: re.colByName("guid")!,
          sessionNumber: int.parse(re.colByName("session_number")!),
          checkNumber: int.parse(re.colByName("check_number")!),
          status: int.parse(re.colByName("status")!),
          paySum: num.parse(re.colByName("pay_sum")!),
          errorMsg: re.colByName("error_msg") != null ? re.colByName("error_msg")! : "",
          univId: re.colByName("univId")!,
          created_at: re.colByName("created_at") != null ? re.colByName("created_at")! : "")
      );
    }

    await conn.close();

    return payments;

  } else {
    throw("Смена не открыта. Для возврата платежа за прошедшие смены обратитесь в поддержку");
  }


}