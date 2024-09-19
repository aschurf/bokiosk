import 'package:bokiosk/controllers/PaymentsController.dart';
import 'package:bokiosk/models/PaymentsModel.dart';
import 'package:bokiosk/pages/AdminPage.dart';
import 'package:bokiosk/pages/ReturnPayPage.dart';
import 'package:flutter/material.dart';

import '../controllers/KkmServerController.dart';

class Historypayments extends StatefulWidget {
  const Historypayments({Key? key}) : super(key: key);

  @override
  State<Historypayments> createState() => _HistorypaymentsState();
}

class _HistorypaymentsState extends State<Historypayments> {

  Future<List<PaymentsModel>>? _listPayments;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listPayments = getPayments();
  }

  showAlertDialog(BuildContext context, int checkNumber) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Отменить", style: TextStyle(fontSize: 30),),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Вернуть", style: TextStyle(fontSize: 30),),
      onPressed:  () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReturnPayPage(checkNumber: checkNumber,)
            ));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Вернуть оплату?", style: TextStyle(fontSize: 50),),
      content: Text("Нажмите вернуть, если требуется полный возврат платежа. Возврат может занять несколько дней в соответствии с условиями банка.", style: TextStyle(fontSize: 30),),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191917),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            FutureBuilder<List<PaymentsModel>>(
              future: _listPayments,
              builder: (context, snapshot){
                if(snapshot.hasData){
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.999,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index){
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          margin: EdgeInsets.only(bottom: 20),
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
                              Column(
                                children: [
                                  Text("Чек №" + snapshot.data![index].checkNumber.toString(),
                                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-ExtraLight')),
                                  Text("Смена №" + snapshot.data![index].sessionNumber.toString() ,
                                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight')),
                                  Text("Сумма " + snapshot.data![index].paySum.toString(),
                                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight')),
                                  Text(snapshot.data![index].status == 1 ? "ОПЛАЧЕНО" : "ВОЗВРАЩЕН",
                                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 30, color: snapshot.data![index].status == 1 ? Colors.green : Colors.red, fontFamily: 'Montserrat-ExtraLight')),
                                ],
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                              snapshot.data![index].status == 1 ? InkWell(
                                onTap: () async {
                                  showAlertDialog(context, snapshot.data![index].checkNumber);
                                },
                                child: Container(
                                  width: 200,
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
                                      Text('Вернуть', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                                    ],
                                  ),
                                ),
                              ) : Container(),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                } else if(snapshot.hasError){
                  return Center(
                    child:  MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.error.toString(),
                        style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight'))),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                );
              },
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminPage()
                    ));
              },
              child: Container(
                child: Center(
                  child:  MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text("Назад",
                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight'))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
