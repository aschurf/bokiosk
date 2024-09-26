import 'dart:convert';
import 'dart:math';
import 'package:bokiosk/constants.dart';
import 'package:bokiosk/models/IikoOrderDishesModel.dart';
import 'package:bokiosk/models/OrderDishesModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';


Future<String> getIikoAuth() async {
  //Получить апи токен
  Map data = {
    'apiLogin': iikoApiLogin,
  };

  var body = json.encode(data);

  print(body);

  final response = await http
      .post(Uri.parse('https://api-ru.iiko.services/api/1/access_token'),
      headers: {"Content-Type": "application/json"},
      body: body);

  final respBody = json.decode(response.body);

  return respBody['token'];
}


Future<void> createOrderTerminal(List<OrderDishesModel> dishes, String checkNumber, int sumOrder, int orderType) async {

  String token = await getIikoAuth();

  List<iikoOrderDishesModel> iikoDishes = [];

  for (var element in dishes) {
    List<iikoOrderDishesModifiersModel> dishModifiers = [];
    for (var modifier in element.modifiers) {
      dishModifiers.add(iikoOrderDishesModifiersModel(
          productId: modifier.id,
          price: modifier.price.toInt(),
          amount: 1
      ));
    }

    iikoDishes.add(iikoOrderDishesModel(
        productId: element.id,
        price: element.price.toInt(),
        type: "Product",
        amount: element.dishCount.toInt(),
        modifiers: dishModifiers
    ));
  }

  Map data = {
    'organizationId': iikoOrganizationId,
    'terminalGroupId': iikoTerminalGroupId,
    'order': {
      "externalNumber": checkNumber,
      "items": iikoDishes,
      "phone": "+79269484308",
      'orderTypeId': orderType == 1 ? iikoOrderTypeHere : iikoOrderTypeTakeAway,
      "customer": {
        "name": "Alex",
        "type": "one-time"
      },
      "payments": [
        {
          "paymentTypeKind": "Card",
          "sum": sumOrder,
          "paymentTypeId": iikoPaymentType,
          "isProcessedExternally": true,
          "isFiscalizedExternally": false,
        }
      ],
    },
  };


  var body = json.encode(data);
  print(body);
  final response = await http
      .post(Uri.parse('https://api-ru.iiko.services/api/1/deliveries/create'),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer " + token},
      body: body);


  print(response.body);

  // final respBody = json.decode(response.body);
}