import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<List<dynamic>> getMenus(String menuId, String orgId) async {

  Map data = {
    'menuId': menuId,
    'depId': orgId,
  };

  print(data);

  var body = json.encode(data);

  final response = await http
      .post(Uri.parse('https://new.procob.io/api/boapp/getMenuForDepartment'),
      headers: {"Content-Type": "application/json"},
      body: body);

  print(response.body);

  List<dynamic> responseMap = json.decode(response.body);

  responseMap.sort((a, b) {
    return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
  });

  return responseMap;

  //
  // Map data = {
  //   'restId': '',
  // };
  //
  // var body = json.encode(data);
  //
  // final response = await http
  //     .get(Uri.parse('https://new.procob.io/api/boapp/getMenuForDepartment'),
  //   headers: {"Content-Type": "application/x-www-form-urlencoded"},);
  //
  // List<dynamic> responseMap = json.decode(response.body);
  //
  // responseMap.sort((a, b) {
  //   return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
  // });
  //
  // print(responseMap);
  //
  // return responseMap;
}


Future<String> sendDataServer() async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'RegisterCheck',
    'NumDevice': '1',
    'Timeout': 30,
    'IdCommand': guid,
    'IsFiscalCheck': true,
    'TypeCheck': 2,
    'NotPrint': false,
    'NumberCopies': 0,
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<List<dynamic>>? _listFuture;
  List<dynamic>? newOrder;
  int sumOrder = 0;
  @override
  void initState() {
    super.initState();
    // initial load
    _listFuture = getMenus('18419', '7ae08cea-95e9-4136-a746-ed0fe8077770');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.99,
              height: MediaQuery.of(context).size.height * 0.99,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.asset('assets/images/logo.jpeg'),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                        )
                      ],
                    ),
                    SizedBox(height: 30,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.99,
                      height: 50,
                      child: Text('Основное', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),),
                    ),
                    SizedBox(height: 30,),
                    FutureBuilder<List<dynamic>>(
                      future: _listFuture,
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.99,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 300,
                                    childAspectRatio: 3 / 2,
                                    crossAxisSpacing: 10,
                                    mainAxisExtent: 400,
                                    mainAxisSpacing: 20),
                                // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                //   crossAxisCount: 3,
                                //   crossAxisSpacing: 10,
                                //   mainAxisExtent: 256,
                                // ),
                                itemCount: snapshot.data!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index){
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    height: 320,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 4,
                                          blurRadius: 4,
                                          offset: Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                      // gradient: LinearGradient(
                                      //   begin: Alignment.centerLeft,
                                      //   end: Alignment.centerRight,
                                      //   colors: [
                                      //     Color(0xFF17181B),
                                      //     Color(0xFF17181B),
                                      //   ],
                                      // ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        snapshot.data![index]['itemSizes'][0]['buttonImageUrl'] != null ? Container(
                                          height: 260,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data![index]['itemSizes'][0]['buttonImageUrl']),
                                                fit: BoxFit.cover),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ) : Container(
                                          height: 260,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: CachedNetworkImageProvider("https://archive.org/download/no-photo-available/no-photo-available.png"),
                                                fit: BoxFit.cover),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![index]['itemSizes'][0]['prices'][0]['price'].toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.red),),),
                                        SizedBox(height: 5,),
                                        // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 24, color: Colors.red))),
                                        SizedBox(height: 10,),
                                        snapshot.data![index]['stopList'] ? Container(
                                            height: 30,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF2E2F36),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: InkWell(
                                              onTap: (){

                                              },
                                              child: Center(child: Text('закончилось', style: TextStyle(color: Colors.white,), textAlign: TextAlign.center,),),
                                            )
                                        ) :
                                        snapshot.data![index]['count'] == 0 ?
                                        Container(
                                            height: 30,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF2E2F36),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: InkWell(
                                              onTap: (){
                                                setState(() {
                                                  snapshot.data![index]['count'] += 1;
                                                  int newSum = 0;
                                                  snapshot.data!.forEach((element) {
                                                    if(element['count'] > 0){
                                                      int ssum = element['count'] * element['itemSizes'][0]['prices'][0]['price'];
                                                      newSum += ssum;
                                                    }
                                                  });
                                                  sumOrder = newSum;
                                                  newOrder = snapshot.data!;
                                                });
                                              },
                                              child: Center(child: Text('в корзину', style: TextStyle(color: Colors.white,), textAlign: TextAlign.center,),),
                                            )
                                        ) :
                                        Container(
                                          height: 30,
                                          width: 200,
                                          padding: EdgeInsets.symmetric(horizontal: 3),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2E2F36),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    snapshot.data![index]['count'] -= 1;
                                                    int newSum = 0;
                                                    snapshot.data!.forEach((element) {
                                                      if(element['count'] > 0){
                                                        int ssum = element['count'] * element['itemSizes'][0]['prices'][0]['price'];
                                                        newSum += ssum;
                                                      }
                                                    });
                                                    sumOrder = newSum;
                                                    newOrder = snapshot.data!;
                                                  });
                                                },
                                                child: Icon(Icons.remove, color: Colors.white, size: 18,),
                                              ),
                                              Text(snapshot.data![index]['count'].toString(), style: TextStyle(color: Colors.white),),
                                              InkWell(
                                                onTap: (){
                                                  setState(() {
                                                    snapshot.data![index]['count'] += 1;
                                                    int newSum = 0;
                                                    snapshot.data!.forEach((element) {
                                                      if(element['count'] > 0){
                                                        int ssum = element['count'] * element['itemSizes'][0]['prices'][0]['price'];
                                                        newSum += ssum;
                                                      }
                                                    });
                                                    sumOrder = newSum;
                                                    newOrder = snapshot.data!;
                                                  });
                                                },
                                                child: Icon(Icons.add, color: Colors.white, size: 18,),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }
                            ),
                          );
                        } else if (snapshot.hasError){
                          return Center(child: Text(snapshot.error.toString(), style: TextStyle(color: Colors.white),));
                        } else {
                          return Container(
                            child: Center(child: CircularProgressIndicator(color: Colors.white,),),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.99,
              height: MediaQuery.of(context).size.height * 0.00,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }
}
