import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:bokiosk/models/OrderDishesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';

import '../controllers/KkmServerController.dart';
import 'WelcomePage.dart';


class PayOrder extends StatefulWidget {
  List<OrderDishesModel> orderDishes;

  PayOrder({Key? key, required this.orderDishes}) : super(key: key);

  @override
  State<PayOrder> createState() => _PayOrderState();
}


class _PayOrderState extends State<PayOrder> {

  String errorMsg = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    preparePayment().then((res){
      toWelcome();
    }).catchError((error){
        setState(() {
          errorMsg = error;
        });
    });
  }

  Future<String> preparePayment () async {
    int counterCheck = 1;
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
        "Text": ">#2#<Кассовый чек",
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

    widget.orderDishes.forEach((dish){
      checkInfo.add({
        "PrintText": {
          "Text": dish.dishCount.toString() + " " + dish.name + "<#0#>" + dish.price.toString() + ".00 * " + dish.dishCount.toString() + " шт. = " + (dish.dishCount * dish.price).toString() + ".00",
          "Font": 3,
        }
      });
      //Регистрация чека в ОФД
      strings.add({
        "Register": {
          "Name": dish.name,
          "Quantity": dish.dishCount,
          "Price": dish.price,
          "Amount": dish.price * dish.dishCount,
          "Department": 1,
          "Tax": -1,
          "SignMethodCalculation": 4,
          "SignCalculationObject": 1,
          "MeasureOfQuantity": 0,
        }
      });

      checkInfo.add({
        "PrintText": {
          "Text": "НДС не облагается",
        }
      });
      checkInfo.add({
        "PrintText": {
          "Text": "",
        }
      });
      counterCheck++;
      sumOrd += dish.dishCount * dish.price;
      dish.modifiers.forEach((modifierInd){
        checkInfo.add({
          "PrintText": {
            "Text": dish.dishCount.toString() + ". " + modifierInd.name + "<#0#>" + modifierInd.price.toString() + ".00 * " + dish.dishCount.toString() + " шт. = " + (dish.dishCount * modifierInd.price).toString() + ".00",
            "Font": 3,
          }
        });

        //Регистрация чека в ОФД
        strings.add({
          "Register": {
            "Name": modifierInd.name,
            "Quantity": dish.dishCount,
            "Price": modifierInd.price,
            "Amount": modifierInd.price * dish.dishCount,
            "Department": 1,
            "Tax": -1,
            "SignMethodCalculation": 4,
            "SignCalculationObject": 1,
            "MeasureOfQuantity": 0,
          }
        });

        checkInfo.add({
          "PrintText": {
            "Text": "НДС не облагается",
          }
        });
        checkInfo.add({
          "PrintText": {
            "Text": "",
          }
        });
        counterCheck++;
        sumOrd += modifierInd.price * dish.dishCount;
      });
    });

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
        "Text": "НОМЕР УСТРОЙСТВА <#20#>00001427",
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
        "Text": "77-Г.Москва, 115191,Мытная ул,д.74,пав 26",
        "Font": 3,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": "Место расчетов <#0#>77-Г.Москва, 115191,Мытная ул,д.74,пав 26",
        "Font": 3,
      }
    });

    await PayAndRegister(0, strings, checkInfo, sumOrd, widget.orderDishes).then((resp){

    }).catchError((error){
      throw(error);
    });

    return 'ok';
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
          errorMsg == "" ? Positioned(
            top: 700,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: 600,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                )
            ),
          ) : Container(),
          errorMsg == "" ? Positioned(
            top: 900,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: 600,
              child: Center(
                child: Text('Следуйте указаниям на терминале', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
              )
            ),
          ) : Positioned(
            top: 900,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: 600,
                child: Center(
                  child: Text(errorMsg, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40, color: Colors.red, fontFamily: 'Montserrat-Regular'), textAlign: TextAlign.center,),
                )
            ),
          )
        ],
      ),
    );
  }
}
