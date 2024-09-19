import 'dart:async';

import 'package:flutter/material.dart';

import 'WelcomePage.dart';

class SuccessPayPage extends StatefulWidget {
  String checkNumber;
  SuccessPayPage({Key? key, required this.checkNumber}) : super(key: key);

  @override
  State<SuccessPayPage> createState() => _SuccessPayPageState();
}

class _SuccessPayPageState extends State<SuccessPayPage> {

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
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => WelcomePage()
              ));
        } else {
          setState(() {
            _start--;
          });
        }
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
    return Scaffold(
      backgroundColor: Color(0xFF191917),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 300,
              child: Container(
                width: 300,
                height: 300,
                child: Image.asset('assets/images/logo2.png'),
              ),
            ),
          ),
          Positioned(
            top: 500,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 150,
                child: Center(
                  child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Номер вашего заказа',
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 60, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold', shadows: [
                    ]), textAlign: TextAlign.center,)),
                )
            ),
          ),
          Positioned(
            top: 600,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 150,
                child: Center(
                  child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(widget.checkNumber,
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 120, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold', shadows: [
                    ]), textAlign: TextAlign.center,)),
                )
            ),
          ),
          Positioned(
            top: 1100,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 150,
                child: Center(
                  child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Пожалуйста, проходите в зону выдачи заказов.',
                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold', shadows: [
                    ]), textAlign: TextAlign.center,)),
                )
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: MediaQuery.of(context).size.height * 0.07,
              color: Color(0xFF42413D),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      _timer.cancel();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage()
                          ));
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
                          Text('Завершить ' + _start.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
