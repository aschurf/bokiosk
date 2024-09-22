import 'package:bokiosk/pages/HomePage.dart';
import 'package:flutter/material.dart';

class OrderTypeSelect extends StatefulWidget {
  const OrderTypeSelect({Key? key}) : super(key: key);

  @override
  State<OrderTypeSelect> createState() => _OrderTypeSelectState();
}

class _OrderTypeSelectState extends State<OrderTypeSelect> {
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
              height: 150,
              child: Container(
                width: 100,
                height: 100,
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
                child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Тип заказа:',
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
              height: 600,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    InkWell(
                      onTap: (){
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
    );
  }
}
