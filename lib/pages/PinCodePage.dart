import 'dart:convert';

import 'package:bokiosk/pages/AdminPage.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

import '../controllers/KkmServerController.dart';

class PinCodePage extends StatefulWidget {
  String code;
  PinCodePage({Key? key, required this.code}) : super(key: key);

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {

  final defaultPinTheme = PinTheme(
    width: 110,
    height: 110,
    textStyle: TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );


  final pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191917),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: 500,
              child: Center(
                child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Введите код доступа',
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 70, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                    ]))),
              ),
            ),
          ),
          Positioned(
            top: 500,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: 500,
              child: Center(
                child: Pinput(
                  controller: pinController,
                  defaultPinTheme: defaultPinTheme,
                  validator: (s) {
                    print(widget.code);
                    if(s == widget.code){
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminPage()
                          ));
                    } else {
                      pinController.text = "";
                      return 'Неправильный код доступа';
                    }
                  },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: false,
                  onCompleted: (pin) => print(pin),
                ),
              )
            ),
          ),
          Positioned(
            top: 1300,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: 500,
              child: VirtualKeyboard(
                  textColor: Colors.white,
                  fontSize: 30,
                  type: VirtualKeyboardType.Numeric,
                  onKeyPress: (key) {
                    if (key.keyType == VirtualKeyboardKeyType.String){
                      pinController.setText(pinController.text + key.text);
                    } else if (key.keyType == VirtualKeyboardKeyType.Action) {

                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
