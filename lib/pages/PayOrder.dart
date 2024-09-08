import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:bokiosk/models/OrderDishesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';

import 'WelcomePage.dart';

Future<String> sendDataServer() async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'RegisterCheck',
    'NumDevice': '4',
    'Timeout': 30,
    'IdCommand': guid,
    'IsFiscalCheck': false,
    'TypeCheck': 2,
    'NotPrint': false,
    'NumberCopies': 2,
    'CashierName': 'Иванов А.В.',
    'CashierVATIN': '772577978824',
    'TaxVariant': '',
    'CorrectionType': 1,
    'CorrectionBaseDate': '2024-09-02T15:30:30',
    'CorrectionBaseNumber': 'MOS-4516',
    'CheckStrings': [
      {
        'PrintText': {
          //При вставке в текст символов ">#10#<" строка при печати выровнеется по центру, где 10 - это на сколько меньше станет строка ККТ
          'Text': ">#2#<ООО \"Рога и копыта\"",
          'Font': 1,
        },
      }
    ],
    'Cash': 800,
    'ElectronicPayment': 0.01,
    'AdvancePayment': 0.02,
    'CashProvision': 0.04,
    'Credit': 0.03,
    'Amount': 1.21,
  };

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse('http://localhost:5894/Execute'),
      headers: {"Content-Type": "application/json"},
      body: body);

  print(response);

  return 'ok';
}


class PayOrder extends StatefulWidget {
  List<OrderDishesModel> orderDishes;
  PayOrder({Key? key, required this.orderDishes}) : super(key: key);

  @override
  State<PayOrder> createState() => _PayOrderState();
}


class _PayOrderState extends State<PayOrder> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sendDataServer().then((res){
      toWelcome();
    });
  }

  void toWelcome(){
    Future((){
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WelcomePage()
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191917),
      body: Stack(
        children: [
          Positioned(
            top: 200,
            left: 240,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                image: DecorationImage(image: ExactAssetImage('assets/images/ekv.png'),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 700,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: 600,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                )
            ),
          ),
          Positioned(
            top: 900,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: 600,
              child: Center(
                child: Text('Следуйте указаниям на терминале', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
              )
            ),
          )
        ],
      ),
    );
  }
}
