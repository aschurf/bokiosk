import 'dart:async';
import 'dart:io';
import 'package:bokiosk/pages/SuccessPayPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:bokiosk/models/OrderDishesModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';

import '../controllers/KkmServerController.dart';
import 'WelcomePage.dart';


class PayOrder extends StatefulWidget {
  List<OrderDishesModel> orderDishes;
  int typeOrder;
  PayOrder({Key? key, required this.orderDishes, required this.typeOrder}) : super(key: key);

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
      toSuccess(res);
    }).catchError((error){
        setState(() {
          errorMsg = error.toString();
        });
        startTimer();
    });
  }

  late Timer _timer;
  int _start = 30;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
          _timer.cancel();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => WelcomePage()
              ),
          (Route<dynamic> route) => false);
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<String> preparePayment () async {
    int counterCheck = 1;
    int sumOrd = 0;
    List<Map> strings = [];
    List<Map> checkInfo = [];
    checkInfo.add({
      "PrintText": {
        "Text": ">#2#<Для ваших отзывов и предложений",
        "Font": 2,
      }
    });
    checkInfo.add({
      "PrintText": {
        "Text": ">#2#<напишите нам",
        "Font": 2,
      }
    });
    checkInfo.add({
      "BarCode": {
        "BarcodeType": "QR",
        "Barcode": "https://taplink.cc/aschurf",
      }
    });
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

    for (var dish in widget.orderDishes) {
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
      sumOrd += dish.dishCount.toInt() * dish.price.toInt();
      for (var modifierInd in dish.modifiers) {
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
        sumOrd += modifierInd.price.toInt() * dish.dishCount.toInt();
      }
    }

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

    String nOr = "";
    await PayAndRegister(strings, checkInfo, sumOrd, widget.orderDishes, widget.typeOrder).then((resp){
      print(resp);
      nOr = resp;
      return resp;
    }).catchError((error){
      throw(error);
    });
    return nOr;
  }

  void toSuccess(res){
    Future((){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuccessPayPage(checkNumber: res,)
          ));
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                  child: Text(errorMsg, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40, color: Color(0xFFD72314), fontFamily: 'Montserrat-Regular'), textAlign: TextAlign.center,),
                )
            ),
          ),
          errorMsg != "" ? Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: MediaQuery.of(context).size.height * 0.07,
              color: Color(0xFF42413D),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      _timer.cancel();
                      Navigator.pop(context, {
                        "dishesOrder": widget.orderDishes
                      });
                    },
                    child: Container(
                      width: 580,
                      height: 90,
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                          SizedBox(width: 30,),
                          Text('Попробовать еще раз', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: (){
                      _timer.cancel();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PayOrder(orderDishes: widget.orderDishes, typeOrder: widget.typeOrder,)
                          ),
                              (Route<dynamic> route) => false);
                    },
                    child: Container(
                      width: 400,
                      height: 90,
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFFD72314),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Отменить ' + _start.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }
}
