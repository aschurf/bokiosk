import 'dart:async';

import 'package:bokiosk/pages/HomePage.dart';
import 'package:flutter/material.dart';

import 'WelcomePage.dart';

class OrderTypeSelect extends StatefulWidget {
  const OrderTypeSelect({Key? key}) : super(key: key);

  @override
  State<OrderTypeSelect> createState() => _OrderTypeSelectState();
}

class _OrderTypeSelectState extends State<OrderTypeSelect> {

  late Timer _timer;
  int _start = 120;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        print(_start);
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => WelcomePage()
              ));
        } else if(_start == 30) {
          showAlertDialogTimer();
          setState(() {
            _start--;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  showAlertDialogTimer() {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("начать заново", style: TextStyle(fontSize: 30),),
      onPressed:  () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomePage()
            ));
        Navigator.pop(context);
        _timer.cancel();
      },
    );
    Widget continueButton = TextButton(
      child: Text("продолжить", style: TextStyle(fontSize: 30),),
      onPressed:  () {
        Navigator.pop(context);
        setState(() {
          _start = 120;
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Вы еще здесь?", style: TextStyle(fontSize: 50),),
      content: Text("Чтобы продолжить оформление заказа, нажмите продолжить", style: TextStyle(fontSize: 30),),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        setState(() {
          _start = 120;
        });
      },
      child: Scaffold(
        backgroundColor: Color(0xFF191917),
        body: Stack(
          children: [
            Positioned(
              top: 100,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 150,
                child: Container(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/images/logo2.png'),
                ),
              ),
            ),
            // Positioned(
            //   top: 500,
            //   left: 0,
            //   child: Container(
            //     width: MediaQuery.of(context).size.width * 0.999,
            //     padding: EdgeInsets.symmetric(horizontal: 20),
            //     height: 150,
            //     child: Center(
            //       child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Тип заказа:',
            //         style: TextStyle(fontWeight: FontWeight.w200, fontSize: 60, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold', shadows: [
            //         ]), textAlign: TextAlign.center,)),
            //     )
            //   ),
            // ),
            Positioned(
              top: 600,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 600,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        _timer.cancel();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(menuId: '31481', typeOrder: 1,)
                            ));
                      },
                      child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFFDB3C33),
                          ),
                          child: Center(
                            child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('В зале',
                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 70, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold', shadows: [
                              ]), textAlign: TextAlign.center,)),
                          )
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        _timer.cancel();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(menuId: '32661', typeOrder: 2,)
                            ));
                      },
                      child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFFDB3C33),
                          ),
                          child: Center(
                            child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('C собой',
                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 70, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold', shadows: [
                              ]), textAlign: TextAlign.center,)),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
