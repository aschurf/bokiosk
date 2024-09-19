import 'dart:convert';
import 'dart:io';

import 'package:bokiosk/pages/HistoryPayments.dart';
import 'package:bokiosk/pages/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../controllers/KkmServerController.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  Map<String, dynamic> kkmState = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    kkm();
  }

  Future<Map> kkm() async {
    var kk = await GetDataKKT();
    var js = json.decode(kk);
    kkmState = js;
    return js;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191917),
      body: FutureBuilder<Map>(
          future: kkm(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Stack(
                children: [
                  Positioned(
                    top: 100,
                    left: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Состояние ККТ:',
                            style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(kkmState['Info']['NameOrganization'],
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(kkmState['Info']['AddressSettle'],
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(kkmState['Info']['NameOFD'],
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Заводской номер ККТ ' + kkmState['Info']['KktNumber'],
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Номер ФН ' + kkmState['Info']['FnNumber'],
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Дата окончания ФН ' + kkmState['Info']['FN_DateEnd'],
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Регистрационный номер ККТ ' + kkmState['Info']['RegNumber'],
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Состояние смены (1 закрыта, 2 открыта, 3 ошибка) = ' + kkmState['Info']['SessionState'].toString(),
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Номер смены = ' + kkmState['SessionNumber'].toString(),
                            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-ExtraLight', shadows: [
                            ]))),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 500,
                    left: 0,
                    child: kkmState['Info']['SessionState'] == 1 ? InkWell(
                      onTap: (){
                        EasyLoading.show(status: 'подождите...');
                        OpenShift().then((res){
                          setState(() {

                          });
                          EasyLoading.dismiss();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        width: 950,
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
                        child: Center(
                          child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Открыть смену',
                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                              ]))),
                        ),
                      ),
                    ) : Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      width: 950,
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
                      child: Center(
                        child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Открыть смену - недоступно',
                            style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                            ]))),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 650,
                    left: 0,
                    child: kkmState['Info']['SessionState'] == 2 || kkmState['Info']['SessionState'] == 3  ? InkWell(
                      onTap: (){
                        EasyLoading.show(status: 'подождите...');
                        CloseShift().then((res){
                          EasyLoading.dismiss();
                          setState(() {

                          });
                          EasyLoading.showSuccess('Смена успешно закрыта');
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        width: 950,
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
                        child: Center(
                          child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Закрыть смену',
                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                              ]))),
                        ),
                      ),
                    ) : Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      width: 950,
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
                      child: Center(
                        child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Закрыть смену - недоступно',
                            style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                            ]))),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 800,
                    left: 0,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Historypayments()
                            ));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        width: 950,
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
                        child: Center(
                          child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Возврат чека',
                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                              ]))),
                        ),
                      ),
                    )
                  ),
                  Positioned(
                    top: 950,
                    left: 0,
                    child: InkWell(
                      onTap: () async {
                        EasyLoading.show(status: 'выключение киоска...');
                        var cleanProcess = await Process.run('shutdown', ["-s"]);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        width: 950,
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
                        child: Center(
                          child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Выключить устройство',
                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                              ]))),
                        ),
                      ),
                    )
                  ),
                  Positioned(
                    top: 1600,
                    left: 0,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomePage()
                            ));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        width: 950,
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
                        child: Center(
                          child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('закрыть и вернуться',
                              style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                              ]))),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }

            return Center(
              child: CircularProgressIndicator(color: Colors.white,),
            );
          }
      )
    );
  }
}
