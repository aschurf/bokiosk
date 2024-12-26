import 'dart:convert';
import 'dart:math';
import 'package:bokiosk/controllers/IikoController.dart';
import 'package:bokiosk/controllers/LogController.dart';
import 'package:bokiosk/opsgenie/opsgenieIncident.dart';
import 'package:intl/intl.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';

import '../constants.dart';
import '../models/OrderDishesModel.dart';
import 'PaymentsController.dart';


Future<Map> getFiscalInfo(int checkNumber) async {
  //Получить данные фискального чека по его номеру
  final String opGuid = Guid.newGuid.toString();
  Map data = {
    'Command': 'GetDataCheck',
    'IdCommand': opGuid,
    'NumDevice': numDeviceKkm,
    'FiscalNumber': checkNumber,
  };

  var body = json.encode(data);

  print(body);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  final respBody = json.decode(response.body);
  final respBodyY = json.encode(respBody);
  print(respBodyY);

  return respBody;
}

Future<String> returnPayment (List<Map> checkStrings, List<Map> checkInfo, num sumOrd, String UniversalID) async {
  //Вернуть платеж по карте
  final String opGuid = Guid.newGuid.toString();
  Map data = {
    'Command': 'ReturnPaymentByPaymentCard',
    'IdCommand': opGuid,
    'NumDevice': numDeviceEkvaring,
    'Amount': sumOrd,
    'UniversalID': UniversalID,
  };

  var body = json.encode(data);

  print(body);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  final respBody = json.decode(response.body);
  final respBodyY = json.encode(respBody);
  print(respBodyY);

  if(respBody['Error'] == ""){

  } else {
    throw("Ошибка возврата платежа " + respBody['Error']);
  }


  //Зарегистрировать возврат в ОФД
  final String guidOfd = Guid.newGuid.toString();
  Map dataOfd = {
    'Command': 'RegisterCheck',
    'IdCommand': guidOfd,
    'NumDevice': numDeviceKkm,
    'Timeout': 60,
    'IsFiscalCheck': true,
    // Тип чека, Тег 1054;
    // 0 – продажа/приход;                                      10 – покупка/расход;
    // 1 – возврат продажи/прихода;                             11 - возврат покупки/расхода;
    // 2 – корректировка продажи/прихода;                       12 – корректировка покупки/расхода;
    // 3 – корректировка возврата продажи/прихода; (>=ФФД 1.1)  13 – корректировка возврата покупки/расхода; (>=ФФД 1.1)
    'TypeCheck': 1,
    'NotPrint': false,
    'NumberCopies': 2,
    'CashierName': 'Иванов А.В.',
    'CashierVATIN': '772577978824',
    // Если надо одновременно автоматически провести транзакцию через эквайринг
    // Эквайринг будет задействован если: 1. чек фискальный, 2. оплата по "ElectronicPayment" не равна 0, 3. PayByProcessing = true
    // Использовать эквайринг: Null - из настроек на сервере, false - не будет, true - будет
    'PayByProcessing': false, //В тестовом чеке автоматический эквайринг выключен
    'NumDeviceByProcessing': numDeviceEkvaring,
    'ReceiptNumber': "TEST-01", // Номер чека для эквайринга
    'PrintSlipAfterCheck': true, // Печатать Слип-чек после чека (а не в чеке)
    'Cash': 0, // Наличная оплата (2 знака после запятой), Тег 1031
    'ElectronicPayment': sumOrd.toInt(), // Сумма электронной оплаты (2 знака после запятой), Тег 1081
    'AdvancePayment': 0, // Сумма из предоплаты (зачетом аванса) (2 знака после запятой), Тег 1215
    'Credit': 0, // Сумма постоплатой(в кредит) (2 знака после запятой), Тег 1216
    'CashProvision': 0, // Сумма оплаты встречным предоставлением (сертификаты, др. мат.ценности) (2 знака после запятой), Тег 1217
    'CheckStrings': checkStrings
  };

  var bodyOfd = json.encode(dataOfd);

  final responseOfd = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyOfd);

  final respBodyOfd = json.decode(responseOfd.body);
  final respBodyYOfd = json.encode(respBodyOfd);
  print(respBodyYOfd);

  if(respBodyOfd['Error'] == ""){

  } else {
    throw("Ошибка ККТ " + respBodyOfd['Error'] == "");
  }

  Map fisInfo = await getFiscalInfo(respBodyOfd['CheckNumber']);
  String dateTimeString = fisInfo['RegisterCheck']['FiscalDate'];
  final dateTime = DateTime.parse(dateTimeString);
  final format = DateFormat('dd.MM.yy H:m');
  final clockString = format.format(dateTime);

  //Распечатать чек возврата
  checkInfo.add({
    "PrintText": {
      "Text": clockString,
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ВОЗВРАТ",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "РН ККТ 0008341297005706",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ЗН ККТ 00107600577322",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ИНН 9723088772",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ФН 7384440800018563",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ФД " + fisInfo['RegisterCheck']['FiscalNumber'],
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ФП " + fisInfo['RegisterCheck']['FiscalSign'],
      "Font": 3,
    }
  });
  checkInfo.add({
    "BarCode": {
      "BarcodeType": "QR",
      "Barcode": fisInfo['QRCode'],
    }
  });

  //Распечатать чек
  final String guidCheckPrint = Guid.newGuid.toString();
  Map dataCheckPrint = {
    'Command': 'PrintDocument',
    'IdCommand': guidCheckPrint,
    'NumDevice': numDevicePrinter,
    'Timeout': 60,
    'CheckStrings': checkInfo,
  };

  var bodyCheckPrint = json.encode(dataCheckPrint);

  final responseCheckPrint = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyCheckPrint);

  final respBodyCheckPrint = json.decode(responseCheckPrint.body);
  final respBodyYCheckPrint = json.encode(respBodyCheckPrint);
  print(respBodyYCheckPrint);

  return "OK";
}

Future<String> PayAndRegister(List<Map> checkStrings, List<Map> checkInfo, num sumOrd, List<OrderDishesModel> orderDishes, int orderType) async {
  //Провести оплату по карте
  final String opGuid = Guid.newGuid.toString();
  Map data = {
    'Command': 'PayByPaymentCard',
    'IdCommand': opGuid,
    'NumDevice': numDeviceEkvaring,
    'Amount': sumOrd,
  };
  logStashSend("Новая оплата " + sumOrd.toString(), "", opGuid);

  var body = json.encode(data);

  print(body);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  final respBody = json.decode(response.body);
  logStashSend(response.body, "", opGuid);
  final respBodyY = json.encode(respBody);

  if(respBody['Error'] == ""){
    //ОПлата прошла успешно
    final conn = await MySQLConnection.createConnection(
      host: mySqlServer,
      port: 3306,
      userName: "kiosk_user",
      password: "Iehbr201010",
      databaseName: "kiosk", // optional
    );

    await conn.connect();

    await conn.execute('insert into payments (guid, univId, ekv_json) values (:guid, :univId,  :ekv_json)', {'guid': opGuid, 'univId': respBody['UniversalID'], 'ekv_json': respBodyY});

    await conn.close();

    logStashSend("Оплата по банку прошла успешно", "", opGuid);
  } else {
    logStashSend("Оплата по банку завершилась ошибкой " + respBody['Error'], "", opGuid);
    throw('Ошибка оплаты: ' + respBody['Error']);
  }

  //Зарегистрировать платеж в ОФД
  final String guidOfd = Guid.newGuid.toString();
  Map dataOfd = {
    'Command': 'RegisterCheck',
    'IdCommand': guidOfd,
    'NumDevice': numDeviceKkm,
    'Timeout': 60,
    'IsFiscalCheck': true,
    // Тип чека, Тег 1054;
    // 0 – продажа/приход;                                      10 – покупка/расход;
    // 1 – возврат продажи/прихода;                             11 - возврат покупки/расхода;
    // 2 – корректировка продажи/прихода;                       12 – корректировка покупки/расхода;
    // 3 – корректировка возврата продажи/прихода; (>=ФФД 1.1)  13 – корректировка возврата покупки/расхода; (>=ФФД 1.1)
    'TypeCheck': 0,
    'NotPrint': false,
    'NumberCopies': 2,
    'CashierName': 'Иванов А.В.',
    'CashierVATIN': '772577978824',
    // Если надо одновременно автоматически провести транзакцию через эквайринг
    // Эквайринг будет задействован если: 1. чек фискальный, 2. оплата по "ElectronicPayment" не равна 0, 3. PayByProcessing = true
    // Использовать эквайринг: Null - из настроек на сервере, false - не будет, true - будет
    'PayByProcessing': false, //В тестовом чеке автоматический эквайринг выключен
    'NumDeviceByProcessing': numDeviceEkvaring,
    'ReceiptNumber': "TEST-01", // Номер чека для эквайринга
    'PrintSlipAfterCheck': true, // Печатать Слип-чек после чека (а не в чеке)
    'Cash': 0, // Наличная оплата (2 знака после запятой), Тег 1031
    'ElectronicPayment': sumOrd.toInt(), // Сумма электронной оплаты (2 знака после запятой), Тег 1081
    'AdvancePayment': 0, // Сумма из предоплаты (зачетом аванса) (2 знака после запятой), Тег 1215
    'Credit': 0, // Сумма постоплатой(в кредит) (2 знака после запятой), Тег 1216
    'CashProvision': 0, // Сумма оплаты встречным предоставлением (сертификаты, др. мат.ценности) (2 знака после запятой), Тег 1217
    'CheckStrings': checkStrings
  };

  var bodyOfd = json.encode(dataOfd);

  final responseOfd = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyOfd);

  final respBodyOfd = json.decode(responseOfd.body);
  logStashSend("Регистрация в ОФД " + responseOfd.body, "", opGuid);
  final respBodyYOfd = json.encode(respBodyOfd);

  if(respBodyOfd['Error'] == ""){
    final conn = await MySQLConnection.createConnection(
      host: mySqlServer,
      port: 3306,
      userName: "kiosk_user",
      password: "Iehbr201010",
      databaseName: "kiosk", // optional
    );

    await conn.connect();

    await conn.execute('UPDATE payments SET session_number = :session_number, check_number = :check_number, pay_sum = :pay_sum, json_resp = :json_resp, status = :status WHERE guid = :guid',
        {
          'guid': opGuid,
          'session_number': respBodyOfd['SessionNumber'],
          'check_number': respBodyOfd['CheckNumber'],
          'status': 1,
          'pay_sum': sumOrd,
          'json_resp': respBodyY,
        });

    await conn.close();

    logStashSend("Регистрация чека в ОФД прошла успешно", "", opGuid);
  } else {
    final String guidRetPay = Guid.newGuid.toString();
    Map dataCheckPrint = {
      'Command': 'EmergencyReversal',
      'IdCommand': guidRetPay,
      'NumDevice': numDeviceEkvaring,
      'Timeout': 60,
      'UniversalID': respBody['UniversalID'],
    };

    var bodyCheckPrint = json.encode(dataCheckPrint);

    await http
        .post(Uri.parse(kkmServerUrl),
        headers: {"Content-Type": "application/json"},
        body: bodyCheckPrint);

    logStashSend("Ошибка формирования чека " + respBodyOfd['Error'], "", opGuid);
    throw ("Ошибка формирования чека, оплата отменена и возвращена: " + respBodyOfd['Error']);
  }

  Map fisInfo = await getFiscalInfo(respBodyOfd['CheckNumber']);
  String dateTimeString = fisInfo['RegisterCheck']['FiscalDate'];
  final dateTime = DateTime.parse(dateTimeString);
  final format = DateFormat('dd.MM.yy H:m');
  final clockString = format.format(dateTime);


  //Сделать номер заказа
  final conn = await MySQLConnection.createConnection(
    host: mySqlServer,
    port: 3306,
    userName: "kiosk_user",
    password: "Iehbr201010",
    databaseName: "kiosk", // optional
  );

  await conn.connect();

  var sNUmber = await conn.execute('SELECT COUNT(id) as counter FROM payments WHERE session_number = :session_number',
      {
        'session_number': respBodyOfd['SessionNumber'],
      });

  String oNumber = "";
  for (final n in sNUmber.rows) {
    oNumber = (int.parse(n.colByName("counter")!) + 1).toString();
  }

  await conn.close();

  var ordNum = "";
  if(orderType == 1){
    ordNum = "H-" + oNumber;
  } else {
    ordNum = "T-" + oNumber;
  }

  logStashSend("Присвоен стартовый номер заказа $ordNum", ordNum, opGuid);
  //Отправляю заказ в IIKO
  String iikoOrderId = "";
  logStashSend("Создаю заказ в IIKO на стол", ordNum, opGuid);
  String error = "";

  if(isIikoLocal == true){
    logStashSend("Создание заказа в Айко локально", ordNum, opGuid);
    //Создание локального заказа IIKO через Плагин
    await createOrderTerminalLocal(orderDishes, ordNum, sumOrd.toInt(), orderType).then((resp) async {
      if(resp.containsKey('success')){
        if(resp['success'] == true){
          ordNum = resp['orderId'].toString();
          logStashSend("Присвоен IIKO номер заказа $ordNum, iiko локально", ordNum, opGuid);
        } else {
          String errMsg = resp['error'];
          logStashSend("Ошибка создания заказа в IIKO локально $errMsg", ordNum, opGuid);
        }
      } else {
        logStashSend("Ошибка создания заказа на стол", ordNum, opGuid);
      }
    }).catchError((error) {
      logStashSend("Ошибка создания заказа на стол" + error.toString(), ordNum, opGuid);
    });
  } else {
    logStashSend("Создание заказа в Айко через Транспорт", ordNum, opGuid);
    //Создание обычного заказа в стол через TransportApi
    await createOrderTerminal(orderDishes, ordNum, sumOrd.toInt(), orderType).then((resp) async {
      if(resp.containsKey('orderInfo')){
        iikoOrderId = resp['orderInfo']['id'];
        logStashSend("ID заказа IIKO = $iikoOrderId", ordNum, opGuid);
        String newOrdNum = "";
        int coun = 0;
        while (newOrdNum == "" && coun < 5){
          sleep(Duration(seconds:3));
          logStashSend("Получение номера заказа от IIKO", ordNum, opGuid);
          await getIikoOrderNumber(resp['orderInfo']['id']).then((orIikoNumber) async {
            insertLog(opGuid, orIikoNumber.toString());
            if(orIikoNumber.containsKey('orders') && orIikoNumber['orders'][0]['order'] != null){
              ordNum = orIikoNumber['orders'][0]['order']['number'].toString();
              newOrdNum = orIikoNumber['orders'][0]['order']['number'].toString();
              logStashSend("Присвоен IIKO номер заказа $ordNum, попытка $coun", ordNum, opGuid);
            } else {
              logStashSend("Ошибка получения номера заказа из IIKO, попытка $coun", ordNum, opGuid);
            }
          }).catchError((error) {
            logStashSend("Ошибка получения номера заказа IIKO" + error.toString(), ordNum, opGuid);
            error = error.toString();
          });
          logStashSend("Подтверждение заказа в IIKO $iikoOrderId", ordNum, opGuid);
          confirmIikoOrder(iikoOrderId);
          coun++;
        }
      } else {
        logStashSend("Ошибка создания заказа на стол", ordNum, opGuid);
      }
    }).catchError((error) {
      logStashSend("Ошибка создания заказа на стол" + error.toString(), ordNum, opGuid);
    });
  }


  final con = await MySQLConnection.createConnection(
    host: mySqlServer,
    port: 3306,
    userName: "kiosk_user",
    password: "Iehbr201010",
    databaseName: "kiosk", // optional
  );

  await con.connect();

  for (var i = 0; i < orderDishes.length; i++){
    await con.execute('INSERT INTO payments_dishes (payment_guid, dish_id, dish_name, dish_count, dish_price) VALUES (:payment_guid, :dish_id, :dish_name, :dish_count, :dish_price)',
        {
          'payment_guid': opGuid,
          'dish_id': orderDishes[i].id,
          'dish_name': orderDishes[i].name,
          'dish_count': orderDishes[i].dishCount,
          'dish_price': orderDishes[i].price,
        });

    for(var b = 0; b < orderDishes[i].modifiers.length; b++){
      await con.execute('INSERT INTO payments_dishes (payment_guid, dish_id, dish_name, dish_count, dish_price) VALUES (:payment_guid, :dish_id, :dish_name, :dish_count, :dish_price)',
          {
            'payment_guid': opGuid,
            'dish_id': orderDishes[i].modifiers[b].id,
            'dish_name': orderDishes[i].modifiers[b].name,
            'dish_count': orderDishes[i].dishCount,
            'dish_price': orderDishes[i].modifiers[b].price,
          });
    }
  }

  await con.close();

  if(ordNum.contains("H") || ordNum.contains("T") || ordNum.contains("Н") || ordNum.contains("Т")){
    logStashSend("5 попыток получения номера заказа завершились неудачей, номер заказа не получен. Сгенерированный номер $ordNum. $adressTitle", ordNum, opGuid);

    //Номер заказа не получен от IIKO
    Map details = {};
    details = {
      "error": error,
      "orderId": opGuid
    };
    sendIncident(
        "Не получен номер заказа от IIKO",
        "5 попыток получения номера заказа завершились неудачей, номер заказа не получен. Сгенерированный номер $ordNum. $adressTitle",
        "P3",
        deviceNumber,
        details
    );

    sleep(Duration(seconds:3));
    logStashSend("Присвоен стартовый номер заказа $ordNum", ordNum, opGuid);
    //Отправляю заказ в IIKO
    logStashSend("Создаю заказ в IIKO на стол ВТОРАЯ ПОПЫТКА", ordNum, opGuid);

    if(iikoOrderId != ""){
      //Заказ был отправлен, но есть проблема с получением номера
      String newOrdNum = "";
      logStashSend("Заказ был отправлен, но есть проблема с получением номера, ID заказа IIKO = $iikoOrderId", ordNum, opGuid);
      int coun = 0;
      while (newOrdNum == "" && coun < 5){
        sleep(Duration(seconds:2));
        logStashSend("Получение номера заказа от IIKO", ordNum, opGuid);
        await getIikoOrderNumber(iikoOrderId).then((orIikoNumber) async {
          insertLog(opGuid, orIikoNumber.toString());
          if(orIikoNumber.containsKey('orders') && orIikoNumber['orders'][0]['order'] != null){
            ordNum = orIikoNumber['orders'][0]['order']['number'].toString();
            newOrdNum = orIikoNumber['orders'][0]['order']['number'].toString();
            logStashSend("Присвоен IIKO номер заказа $ordNum, попытка $coun", ordNum, opGuid);
          } else {
            logStashSend("Ошибка получения номера заказа из IIKO, попытка $coun", ordNum, opGuid);
          }
        }).catchError((error) {
          logStashSend("Ошибка получения номера заказа IIKO" + error.toString(), ordNum, opGuid);
          error = error.toString();
        });
        logStashSend("Подтверждение заказа в IIKO $iikoOrderId", ordNum, opGuid);
        confirmIikoOrder(iikoOrderId);
        coun++;
      }
    } else {
      logStashSend("Не получен ID заказа из Айко, пробую еще раз", ordNum, opGuid);
      await createOrderTerminal(orderDishes, ordNum, sumOrd.toInt(), orderType).then((resp) async {
        if(resp.containsKey('orderInfo')){
          iikoOrderId = resp['orderInfo']['id'];
          logStashSend("ID заказа IIKO = $iikoOrderId", ordNum, opGuid);
          String newOrdNum = "";
          int coun = 0;
          while (newOrdNum == "" && coun < 5){
            sleep(Duration(seconds:3));
            logStashSend("Получение номера заказа от IIKO", ordNum, opGuid);
            await getIikoOrderNumber(resp['orderInfo']['id']).then((orIikoNumber) async {
              insertLog(opGuid, orIikoNumber.toString());
              if(orIikoNumber.containsKey('orders') && orIikoNumber['orders'][0]['order'] != null){
                ordNum = orIikoNumber['orders'][0]['order']['number'].toString();
                newOrdNum = orIikoNumber['orders'][0]['order']['number'].toString();
                logStashSend("Присвоен IIKO номер заказа $ordNum, попытка $coun", ordNum, opGuid);
              } else {
                logStashSend("Ошибка получения номера заказа из IIKO, попытка $coun", ordNum, opGuid);
              }
            }).catchError((error) {
              logStashSend("Ошибка получения номера заказа IIKO" + error.toString(), ordNum, opGuid);
              error = error.toString();
            });
            logStashSend("Подтверждение заказа в IIKO $iikoOrderId", ordNum, opGuid);
            confirmIikoOrder(iikoOrderId);
            coun++;
          }
        } else {
          logStashSend("Ошибка создания заказа на стол", ordNum, opGuid);
        }
      }).catchError((error) {
        logStashSend("Ошибка создания заказа на стол" + error.toString(), ordNum, opGuid);
      });
    }

  }
  //Распечатать чек
  checkInfo.add({
    "PrintText": {
      "Text": clockString,
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ПРИХОД",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "РН ККТ 0008341297005706",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ЗН ККТ 00107600577322",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ИНН 9723088772",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ФН 7384440800018563",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ФД " + fisInfo['RegisterCheck']['FiscalNumber'],
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "ФП " + fisInfo['RegisterCheck']['FiscalSign'],
      "Font": 3,
    }
  });
  checkInfo.add({
    "BarCode": {
      "BarcodeType": "QR",
      "Barcode": fisInfo['QRCode'],
    }
  });

  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });

  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<НОМЕР ВАШЕГО ЗАКАЗА",
      "Font": 1,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<" + ordNum,
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
      "Text": "<<->>",
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<Проходите в зону выдачи",
      "Font": 1,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });


  //Распечатать чек
  final String guidCheckPrint = Guid.newGuid.toString();
  Map dataCheckPrint = {
    'Command': 'PrintDocument',
    'IdCommand': guidCheckPrint,
    'NumDevice': numDevicePrinter,
    'Timeout': 60,
    'CheckStrings': checkInfo,
  };

  var bodyCheckPrint = json.encode(dataCheckPrint);

  final responseCheckPrint = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyCheckPrint);

  logStashSend("Отправка чека на печать на принтер " + responseCheckPrint.body, ordNum, opGuid);

  final respBodyCheckPrint = json.decode(responseCheckPrint.body);
  final respBodyYCheckPrint = json.encode(respBodyCheckPrint);
  print(respBodyYCheckPrint);


  if(respBodyCheckPrint['Error'] == ""){
    logStashSend("Чек распечатан успешно", ordNum, opGuid);
  } else {
    logStashSend("Ошибка печати чека: " + respBodyOfd['Error'], ordNum, opGuid);
    throw ("Ошибка печати чека: " + respBodyOfd['Error']);
  }

  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<Спасибо за покупку!",
      "Font": 3,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });

  // //Распечатать чек
  // final String guidCheckPrintSmall = Guid.newGuid.toString();
  // Map dataCheckPrintSmall = {
  //   'Command': 'PrintDocument',
  //   'IdCommand': guidCheckPrintSmall,
  //   'NumDevice': numDevicePrinterSmall,
  //   'Timeout': 60,
  //   'CheckStrings': checkInfo,
  // };
  //
  // var bodyCheckPrintSmall = json.encode(dataCheckPrintSmall);
  //
  //  http
  //     .post(Uri.parse(kkmServerUrl),
  //     headers: {"Content-Type": "application/json"},
  //     body: bodyCheckPrintSmall);

  logStashSend("Номер заказа возвращен для показа гостю $ordNum", ordNum, opGuid);
   return ordNum;
}


Future<String> PrintCheck(int typeCheck, List<Map> checkStrings, num sumOrd) async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'PrintDocument',
    'IdCommand': guid,
    'NumDevice': numDeviceKkm,
    'Timeout': 60,
  };

  var body = json.encode(data);

  print(body);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  final respBody = json.decode(response.body);
  final respBodyY = json.encode(respBody);
  print(respBodyY);

  final conn = await MySQLConnection.createConnection(
    host: mySqlServer,
    port: 3306,
    userName: "kiosk_user",
    password: "Iehbr201010",
    databaseName: "kiosk", // optional
  );

  await conn.connect();

  await conn.execute('insert into shifts (json_req, json_resp) values (:json_req, :json_resp)', {'json_req': body, 'json_resp': respBodyY});

  await conn.close();

  return response.body;
}

Future<String> ReturnPayment() async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'ReturnPaymentByPaymentCard',
    'IdCommand': guid,
    'NumDevice': numDeviceEkvaring,
    'UniversalID': "CN:************8584;RN:TEST-01;RRN:426210656485;AC:089901;CH:436E6B19518A1A062183EA148FFB6AB879B10BBC",
    'Amount': 490,
  };

  var body = json.encode(data);

  print(body);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  final respBody = json.decode(response.body);
  final respBodyY = json.encode(respBody);
  print(respBodyY);
  return response.body;

}



Future<String> OpenShift() async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'OpenShift',
    'IdCommand': guid,
    'NumDevice': numDeviceKkm,
    'NotPrint': false
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);


  logStashSend("Открытие смены, код доступа " + response.body, "", "");

  final conn = await MySQLConnection.createConnection(
    host: mySqlServer,
    port: 3306,
    userName: "kiosk_user",
    password: "Iehbr201010",
    databaseName: "kiosk", // optional
  );

  final respBody = json.decode(response.body);
  final respBodyY = json.encode(respBody);
  print(respBodyY);

  await conn.connect();

  Random random = new Random();
  int randomNumber = 1000 + random.nextInt(9000);

  logStashSend("Открытие смены, код доступа " + randomNumber.toString(), "", "");

  await conn.execute('insert into shifts (guid, kkm_command, shift_code, check_number, session_number, qr_code, error, json_req, json_resp) values (:guid, :kkm_command, :shift_code, :check_number, :session_number, :qr_code, :error, :json_req, :json_resp)',
      {
        'guid': guid,
        'kkm_command': 'OpenShift',
        'shift_code': randomNumber,
        'check_number': respBody['CheckNumber'],
        'session_number': respBody['SessionNumber'],
        'qr_code': respBody['QRCode'],
        'error': respBody['Error'],
        'json_req': body,
        'json_resp': respBodyY
      });

  await conn.close();

  //Распечатать информационный чек
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
      "Text": ">#2#<Открытие смены",
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

  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<ВАШ ПАРОЛЬ",
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
      "Text": ">#2#<$randomNumber",
      "Font": 1,
    }
  });

  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<Сохраните пароль для доступа к настройкам",
      "Font": 2,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<Смена открыта",
      "Font": 2,
    }
  });

  //Распечатать чек
  final String guidCheckPrint = Guid.newGuid.toString();
  Map dataCheckPrint = {
    'Command': 'PrintDocument',
    'IdCommand': guidCheckPrint,
    'NumDevice': numDevicePrinter,
    'Timeout': 60,
    'CheckStrings': checkInfo,
  };

  var bodyCheckPrint = json.encode(dataCheckPrint);

  final responseCheckPrint = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyCheckPrint);

  final respBodyCheckPrint = json.decode(responseCheckPrint.body);
  logStashSend("Открытие смены, печать чека " + responseCheckPrint.body, "", "");
  final respBodyYCheckPrint = json.encode(respBodyCheckPrint);
  print(respBodyYCheckPrint);

  return response.body;
}

Future<String> CloseShift() async {
  //Закрыть смену по банку (сверка итогов)
  //Вернуть платеж по карте
  final String opGuid = Guid.newGuid.toString();
  Map dataBank = {
    'Command': 'Settlement',
    'IdCommand': opGuid,
    'NumDevice': numDeviceEkvaring,
  };

  var bodyBank = json.encode(dataBank);

  final responseBank = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyBank);

  final respBodyBank = json.decode(responseBank.body);
  logStashSend("Закрытие смены " + responseBank.body, "", "");
  final respBodyYBank = json.encode(respBodyBank);
  print(respBodyYBank);

  if(respBodyBank['Error'] == ""){

  } else {
    logStashSend("Ошибка Закрытие смены " + respBodyBank['Error'], "", "");
    throw("Ошибка возврата платежа " + respBodyBank['Error']);
  }

  await printZReport();


  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'CloseShift',
    'IdCommand': guid,
    'NumDevice': numDeviceKkm,
    'NotPrint': false,
    'CashierName': 'Иванов А.В.',
    'CashierVATIN': '772577978824',
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  print(response.body);

  final String guidEkv = Guid.newGuid.toString();
  Map dataEkv = {
    'Command': 'Settlement',
    'IdCommand': guidEkv,
    'NumDevice': numDeviceEkvaring,
  };

  var bodyEkv = json.encode(dataEkv);

  final responseEkv = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyEkv);

  print(responseEkv.body);

  final conn = await MySQLConnection.createConnection(
    host: mySqlServer,
    port: 3306,
    userName: "kiosk_user",
    password: "Iehbr201010",
    databaseName: "kiosk", // optional
  );

  final respBody = json.decode(response.body);
  final respBodyY = json.encode(respBody);
  print(respBodyY);

  await conn.connect();

  Random random = new Random();
  int randomNumber = random.nextInt(9999);

  await conn.execute('insert into shifts (guid, kkm_command, shift_code, check_number, session_number, qr_code, error, json_req, json_resp) values (:guid, :kkm_command, :shift_code, :check_number, :session_number, :qr_code, :error, :json_req, :json_resp)',
      {
        'guid': guid,
        'kkm_command': 'CloseShift',
        'shift_code': randomNumber,
        'check_number': respBody['CheckNumber'],
        'session_number': respBody['SessionNumber'],
        'qr_code': respBody['QRCode'],
        'error': respBody['Error'],
        'json_req': body,
        'json_resp': respBodyY
      });

  await conn.close();

  return response.body;
}

Future<String> GetDataKKT() async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'GetDataKKT',
    'IdCommand': guid,
    'NumDevice': numDeviceKkm,
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  print(response.body);

  return response.body;
}

Future<void> printXReport() async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'GetCounters',
    'IdCommand': guid,
    'NumDevice': numDeviceKkm,
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  logStashSend("Печать Х-отчета, ответ ККМ GetСounters " + response.body, "", "");
  Map respBody = json.decode(response.body);

  String key = "";
  if(respBody.containsKey('Counters')){
    key = 'Counters';
  }

  if(respBody.containsKey('Сounters')){
    key = 'Сounters';
  }

  List<Map> checkInfo = [];
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });
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
      "Text": ">#2#<X-отчет",
      "Font": 2,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });


  if(respBody['Error'] == ""){
    print("Подготовка х отчета к печати");
    checkInfo.add({
      "PrintText": {
        "Text": "Количество чеков <#0#>=" + (respBody[key][4]['Count'] + respBody[key][5]['Count']).toString(),
        "Font": 3,
      }
    });

    print(checkInfo);
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Количество чеков приходов<#0#>=" + respBody[key][4]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Сумма чеков приходов<#0#>=" + respBody[key][4]['Sum'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Наличными <#0#>=" + respBody[key][4]['Cash'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Банк картами <#0#>=" + respBody[key][4]['ElectronicPayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Предварительных оплат (авансами) <#0#>=" + respBody[key][4]['AdvancePayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Последующих оплат (кредитами) <#0#>=" + respBody[key][4]['Credit'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Другие формы оплаты <#0#>=" + respBody[key][4]['CashProvision'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 20% <#0#>=" + respBody[key][4]['Tax20'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% <#0#>=" + respBody[key][4]['Tax10'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% <#0#>=" + respBody[key][4]['Tax10'].toString(),
        "Font": 3,
      }
    });


    //Возвраты
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Количество чеков возвр приходов<#0#>=" + respBody[key][5]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Сумма чеков возвр приходов<#0#>=" + respBody[key][5]['Sum'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Наличными возвр <#0#>=" + respBody[key][5]['Cash'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Банк картами возвр <#0#>=" + respBody[key][5]['ElectronicPayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Предварительных оплат (авансами) возвр <#0#>=" + respBody[key][5]['AdvancePayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Последующих оплат (кредитами) возвр <#0#>=" + respBody[key][5]['Credit'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Другие формы оплаты возвр <#0#>=" + respBody[key][5]['CashProvision'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 20% возвр <#0#>=" + respBody[key][5]['Tax20'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% возвр <#0#>=" + respBody[key][5]['Tax10'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% возвр <#0#>=" + respBody[key][5]['Tax10'].toString(),
        "Font": 3,
      }
    });


    //Расходы
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Количество чеков расх приходов<#0#>=" + respBody[key][6]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Сумма чеков расх приходов<#0#>=" + respBody[key][6]['Sum'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Наличными расх <#0#>=" + respBody[key][6]['Cash'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Банк картами расх <#0#>=" + respBody[key][6]['ElectronicPayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Предварительных оплат (авансами) расх <#0#>=" + respBody[key][6]['AdvancePayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Последующих оплат (кредитами) расх <#0#>=" + respBody[key][6]['Credit'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Другие формы оплаты расх <#0#>=" + respBody[key][6]['CashProvision'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 20% расх <#0#>=" + respBody[key][6]['Tax20'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% расх <#0#>=" + respBody[key][6]['Tax10'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% расх <#0#>=" + respBody[key][6]['Tax10'].toString(),
        "Font": 3,
      }
    });

    print(checkInfo);

    //Распечатать Отчет
    final String guidCheckPrint = Guid.newGuid.toString();
    Map dataCheckPrint = {
      'Command': 'PrintDocument',
      'IdCommand': guidCheckPrint,
      'NumDevice': numDevicePrinter,
      'Timeout': 60,
      'CheckStrings': checkInfo,
    };

    var bodyCheckPrint = json.encode(dataCheckPrint);

    print(bodyCheckPrint);

    final responseCheckPrint = await http
        .post(Uri.parse(kkmServerUrl),
        headers: {"Content-Type": "application/json"},
        body: bodyCheckPrint);

    logStashSend("Печать Х-отчета" + responseCheckPrint.body, "", "");
  } else {
    logStashSend("Ошибка печати Х-отчета " + respBody['Error'], "", "");
  }


}

Future<void> printZReport() async {
  var kk = await GetDataKKT();
  var js = json.decode(kk);

  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'GetCounters',
    'IdCommand': guid,
    'NumDevice': numDeviceKkm,
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: body);

  logStashSend("Печать Z-отчета, ответ ККМ " + response.body, "", "");

  Map respBody = json.decode(response.body);

  String key = "";
  if(respBody.containsKey('Counters')){
    key = 'Counters';
  }

  if(respBody.containsKey('Сounters')){
    key = 'Сounters';
  }


  List<Map> checkInfo = [];
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });
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
      "Text": ">#2#<Z-отчет",
      "Font": 2,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": ">#2#<Смена №" + js['SessionNumber'].toString(),
      "Font": 2,
    }
  });
  checkInfo.add({
    "PrintText": {
      "Text": "<<->>",
    }
  });

  if(respBody['Error'] == ""){

    checkInfo.add({
      "PrintText": {
        "Text": ">#2#<Необнуляемая сумма на начало смены",
        "Font": 2,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Продажи <#0#>=" + respBody[key][0]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Возврат продажи <#0#>=" + respBody[key][1]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Покупка <#0#>=" + respBody[key][2]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Возврат покупка <#0#>=" + respBody[key][3]['Count'].toString(),
        "Font": 3,
      }
    });


    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Количество чеков приходов<#0#>=" + respBody[key][4]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Сумма чеков приходов<#0#>=" + respBody[key][4]['Sum'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Наличными <#0#>=" + respBody[key][4]['Cash'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Банк картами <#0#>=" + respBody[key][4]['ElectronicPayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Предварительных оплат (авансами) <#0#>=" + respBody[key][4]['AdvancePayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Последующих оплат (кредитами) <#0#>=" + respBody[key][4]['Credit'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Другие формы оплаты <#0#>=" + respBody[key][4]['CashProvision'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 20% <#0#>=" + respBody[key][4]['Tax20'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% <#0#>=" + respBody[key][4]['Tax10'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% <#0#>=" + respBody[key][4]['Tax10'].toString(),
        "Font": 3,
      }
    });


    //Возвраты
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Количество чеков возвр приходов<#0#>=" + respBody[key][5]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Сумма чеков возвр приходов<#0#>=" + respBody[key][5]['Sum'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Наличными возвр <#0#>=" + respBody[key][5]['Cash'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Банк картами возвр <#0#>=" + respBody[key][5]['ElectronicPayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Предварительных оплат (авансами) возвр <#0#>=" + respBody[key][5]['AdvancePayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Последующих оплат (кредитами) возвр <#0#>=" + respBody[key][5]['Credit'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Другие формы оплаты возвр <#0#>=" + respBody[key][5]['CashProvision'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 20% возвр <#0#>=" + respBody[key][5]['Tax20'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% возвр <#0#>=" + respBody[key][5]['Tax10'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% возвр <#0#>=" + respBody[key][5]['Tax10'].toString(),
        "Font": 3,
      }
    });


    //Расходы
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Количество чеков расх приходов<#0#>=" + respBody[key][6]['Count'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Сумма чеков расх приходов<#0#>=" + respBody[key][6]['Sum'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Наличными расх <#0#>=" + respBody[key][6]['Cash'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Банк картами расх <#0#>=" + respBody[key][6]['ElectronicPayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Предварительных оплат (авансами) расх <#0#>=" + respBody[key][6]['AdvancePayment'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Последующих оплат (кредитами) расх <#0#>=" + respBody[key][6]['Credit'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Другие формы оплаты расх <#0#>=" + respBody[key][6]['CashProvision'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 20% расх <#0#>=" + respBody[key][6]['Tax20'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% расх <#0#>=" + respBody[key][6]['Tax10'].toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "НДС 10% расх <#0#>=" + respBody[key][6]['Tax10'].toString(),
        "Font": 3,
      }
    });

    //Итоги
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Кол-во чеков за смену <#0#>=" + (respBody[key][4]['Count'] + respBody[key][5]['Count']).toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Кол-во чеков за весь период <#0#>=" + (respBody[key][0]['Count'] + respBody[key][1]['Count']).toString(),
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "<<->>",
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": ">#2#<КОНЕЦ ОТЧЕТА",
        "Font": 2,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": ">#2#<смена закрыта",
        "Font": 2,
      }
    });


    //Распечатать Отчет
    final String guidCheckPrint = Guid.newGuid.toString();
    Map dataCheckPrint = {
      'Command': 'PrintDocument',
      'IdCommand': guidCheckPrint,
      'NumDevice': numDevicePrinter,
      'Timeout': 60,
      'CheckStrings': checkInfo,
    };

    var bodyCheckPrint = json.encode(dataCheckPrint);

    final responseCheckPrint = await http
        .post(Uri.parse(kkmServerUrl),
        headers: {"Content-Type": "application/json"},
        body: bodyCheckPrint);

    logStashSend("Печать Z-отчета " + responseCheckPrint.body, "", "");
  } else {
    logStashSend("Ошибка печати Z-отчета " + respBody['Error'], "", "");
  }


}