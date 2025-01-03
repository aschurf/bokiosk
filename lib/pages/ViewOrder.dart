import 'dart:async';

import 'package:bokiosk/controllers/KkmServerController.dart';
import 'package:bokiosk/models/OrderDishesModel.dart';
import 'package:bokiosk/pages/PayOrder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:galileo_sqljocky5/public/connection/connection.dart';
import 'package:mysql_client/mysql_client.dart';

import 'WelcomePage.dart';

class ViewOrder extends StatefulWidget {
  List<OrderDishesModel> orderDishes;
  int typeOrder;
  ViewOrder({Key? key, required this.orderDishes, required this.typeOrder}) : super(key: key);

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {

  num fullsUmOrder = 0;

  void reSum(BuildContext context){
    fullsUmOrder = 0;
    widget.orderDishes.forEach((dish){
      fullsUmOrder += dish.price * dish.dishCount;
      dish.modifiers.forEach((modifier){
        fullsUmOrder += modifier.price * dish.dishCount;
      });
    });
    setState(() {

    });
    if(widget.orderDishes.length == 0){
      Navigator.pop(context, {
        "dishesOrder": widget.orderDishes
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
    widget.orderDishes.forEach((dish){
      fullsUmOrder += dish.price * dish.dishCount;
      dish.modifiers.forEach((modifier){
        fullsUmOrder += modifier.price * dish.dishCount;
      });
    });
  }


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
        Navigator.pop(context);
        _timer.cancel();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomePage()
            ),
        (Route<dynamic> route) => false);
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
  void dispose() {
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
              top: 50,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width * 0.999,
                height: 1700,
                child: ListView.builder(
                  itemCount: widget.orderDishes.length,
                  itemBuilder: (context, dishIndex){
                    return Container(
                        width: MediaQuery.of(context).size.width * 0.999,
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF302F2D),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 8,
                              blurRadius: 20,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: CachedNetworkImageProvider(widget.orderDishes[dishIndex].imageUrl),
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                SizedBox(width: 30,),
                                Container(
                                  width: 500,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(widget.orderDishes[dishIndex].name,
                                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                                              ]))),
                                        ],
                                      ),
                                      MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(widget.orderDishes[dishIndex].dishCount.toString() + ' x ' + widget.orderDishes[dishIndex].price.toString(),
                                          style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                                          ]))),
                                      SizedBox(height: 20,),
                                      ListView.builder(
                                        itemCount: widget.orderDishes[dishIndex].modifiers.length,
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, modifierIndex){
                                          return Container(
                                            width: 400,
                                            child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(widget.orderDishes[dishIndex].modifiers[modifierIndex].name,
                                                style: TextStyle(fontWeight: FontWeight.w200, fontSize: 25, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                                                ]))),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            InkWell(
                              onTap: (){

                              },
                              child: Container(
                                width: 250,
                                height: 100,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Color(0xFF54534F)),
                                  color: Color(0xFF54534F),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        setState(() {
                                          if(widget.orderDishes[dishIndex].dishCount == 1){
                                            widget.orderDishes.removeAt(dishIndex);
                                          } else {
                                            if(widget.orderDishes[dishIndex].dishCount > 1){
                                              widget.orderDishes[dishIndex].dishCount--;
                                            }
                                          }
                                        });

                                        reSum(context);
                                      },
                                      child: Icon(Icons.remove, color: Colors.white, size: 65,),
                                    ),
                                    Text(widget.orderDishes[dishIndex].dishCount.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 55, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                                    InkWell(
                                      onTap: (){
                                        setState(() {
                                          if(widget.orderDishes[dishIndex].isMark){
                                            widget.orderDishes.add(widget.orderDishes[dishIndex]);
                                          } else {
                                            widget.orderDishes[dishIndex].dishCount++!;
                                          }
                                        });
                                        reSum(context);
                                      },
                                      child: Icon(Icons.add, color: Color(0xFFD6D5D1), size: 65,),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                    );
                  },
                ),
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
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context, {
                          "dishesOrder": widget.orderDishes
                        });
                      },
                      child: Container(
                        width: 400,
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
                            Text('Выбор блюд', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 80,),
                    InkWell(
                      onTap: (){
                        _timer.cancel();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PayOrder(orderDishes: widget.orderDishes, typeOrder: widget.typeOrder,)
                            ));
                      },
                      child: Container(
                        width: 500,
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
                            Text('Оплатить  ' + fullsUmOrder.toString() + ' руб.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
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
      ),
    );
  }
}
