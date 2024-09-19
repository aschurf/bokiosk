import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';

import '../constants.dart';
import '../models/OrderDishesModel.dart';


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
  } else {
    print('Ошибка оплаты: ' + respBody['Error']);
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
  final respBodyYOfd = json.encode(respBodyOfd);
  print("Результат ОФД = ");
  print(respBodyYOfd);

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

    print("Ошибка формирования чека: " + respBodyOfd['Error']);
    throw ("Ошибка формирования чека: " + respBodyOfd['Error']);
  }

  Map fisInfo = await getFiscalInfo(respBodyOfd['CheckNumber']);
  String dateTimeString = fisInfo['RegisterCheck']['FiscalDate'];
  final dateTime = DateTime.parse(dateTimeString);
  final format = DateFormat('dd.MM.yy H:m');
  final clockString = format.format(dateTime);

  print("Дата время фискального чека");
  print(clockString);

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

  //Распечатать чек возврата
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

  if(orderType == 1){
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
        "Text": ">#2#<H-" + oNumber,
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
  } else {
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
      "Text": ">#2#<T-" + oNumber,
      "Font": 1,
      }
    });
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
  }


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


  if(respBodyCheckPrint['Error'] == ""){
    final conn = await MySQLConnection.createConnection(
      host: mySqlServer,
      port: 3306,
      userName: "kiosk_user",
      password: "Iehbr201010",
      databaseName: "kiosk", // optional
    );

    await conn.connect();

    for (var i = 0; i < orderDishes.length; i++){
      await conn.execute('INSERT INTO payments_dishes (payment_guid, dish_id, dish_name, dish_count, dish_price) VALUES (:payment_guid, :dish_id, :dish_name, :dish_count, :dish_price)',
          {
            'payment_guid': opGuid,
            'dish_id': orderDishes[i].id,
            'dish_name': orderDishes[i].name,
            'dish_count': orderDishes[i].dishCount,
            'dish_price': orderDishes[i].price,
          });

      for(var b = 0; b < orderDishes[i].modifiers.length; b++){
        await conn.execute('INSERT INTO payments_dishes (payment_guid, dish_id, dish_name, dish_count, dish_price) VALUES (:payment_guid, :dish_id, :dish_name, :dish_count, :dish_price)',
            {
              'payment_guid': opGuid,
              'dish_id': orderDishes[i].modifiers[b].id,
              'dish_name': orderDishes[i].modifiers[b].name,
              'dish_count': orderDishes[i].dishCount,
              'dish_price': orderDishes[i].modifiers[b].price,
            });
      }
    }

    await conn.close();
  } else {
    print("Ошибка печати чека: " + respBodyOfd['Error']);
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

  //Распечатать чек
  final String guidCheckPrintSmall = Guid.newGuid.toString();
  Map dataCheckPrintSmall = {
    'Command': 'PrintDocument',
    'IdCommand': guidCheckPrintSmall,
    'NumDevice': numDevicePrinterSmall,
    'Timeout': 60,
    'CheckStrings': checkInfo,
  };

  var bodyCheckPrintSmall = json.encode(dataCheckPrintSmall);

   http
      .post(Uri.parse(kkmServerUrl),
      headers: {"Content-Type": "application/json"},
      body: bodyCheckPrintSmall);

   if(orderType == 1){
     return "H-" + oNumber;
   } else {
     return "T-" + oNumber;
   }
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

  print(response.body);


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
  final respBodyYBank = json.encode(respBodyBank);
  print(respBodyYBank);

  if(respBodyBank['Error'] == ""){

  } else {
    throw("Ошибка возврата платежа " + respBodyBank['Error']);
  }


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