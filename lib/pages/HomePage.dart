import 'dart:convert';

import 'package:bokiosk/models/MenuModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;



List<MenuModel> parseGetPayment(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<MenuModel>((json) => MenuModel.fromJson(json)).toList();
}

Future<List<MenuModel>> getMenus(String menuId, String orgId) async {

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

  return parseGetPayment(response.body);
}


Future<String> sendDataServer() async {
  final String guid = Guid.newGuid.toString();
  Map data = {
    'Command': 'RegisterCheck',
    'NumDevice': '4',
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

  Future<List<MenuModel>>? _listFuture;
  List<dynamic>? newOrder;
  num sumOrder = 0;
  @override
  void initState() {
    super.initState();
    // initial load
    _listFuture = getMenus('31481', '7ae08cea-95e9-4136-a746-ed0fe8077770');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEDED),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.99,
              height: MediaQuery.of(context).size.height * 0.99,
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
                    SizedBox(height: 30,),
                    FutureBuilder<List<MenuModel>>(
                      future: _listFuture,
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, groupIndex){
                              return Column(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.99,
                                    child: Text(snapshot.data![groupIndex].name, style: TextStyle(fontFamily: 'Montserrat-Regular', fontSize: 24),),
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                  ),
                                  GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 450,
                                          childAspectRatio: 3 / 2,
                                          crossAxisSpacing: 10,
                                          mainAxisExtent: 470,
                                          mainAxisSpacing: 10),
                                      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      //   crossAxisCount: 3,
                                      //   crossAxisSpacing: 10,
                                      //   mainAxisExtent: 256,
                                      // ),
                                      itemCount: snapshot.data![groupIndex].items.length,
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index){
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                                          margin: EdgeInsets.symmetric(horizontal: 5),
                                          height: 350,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFFE8E0DD),
                                                spreadRadius: 8,
                                                blurRadius: 20,
                                                offset: Offset(-2, 4), // changes position of shadow
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
                                              snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl != '' ? Container(
                                                height: 280,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl),
                                                      fit: BoxFit.cover),
                                                  borderRadius: BorderRadius.circular(6),
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
                                              // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                              MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].name,
                                                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 24, color: Colors.red, fontFamily: 'Montserrat-Medium'))),
                                              SizedBox(height: 5,),
                                              // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                              MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesPrices[0].price.toString(),
                                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.red, fontFamily: 'Montserrat-Regular'),),),
                                              SizedBox(height: 5,),
                                              // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                              MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].portionWeightGrams.toStringAsFixed(0) + ' г',
                                                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black, fontFamily: 'Montserrat-Regular'),),),
                                              SizedBox(height: 2,),
                                              snapshot.data![groupIndex].items[index].stopList ? Container(
                                                  height: 30,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF2E2F36),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: InkWell(
                                                    onTap: (){
                                                      sendDataServer().then((res) => {

                                                      });
                                                    },
                                                    child: Center(child: Text('закончилось', style: TextStyle(color: Colors.white,), textAlign: TextAlign.center,),),
                                                  )
                                              ) :
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 60,
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(color: Colors.black)
                                                      ),
                                                      child: Icon(Icons.remove),
                                                    ),
                                                    Container(
                                                      child: Text(snapshot.data![groupIndex].items[index].count.toString(), style: TextStyle(fontSize: 50),),
                                                    ),
                                                    InkWell(
                                                      onTap: (){
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return  SafeArea(
                                                              child: Container(
                                                                  padding: EdgeInsets.all(0) ,
                                                                  child: Dialog(
                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                      child: Container(
                                                                          width: 700,
                                                                          child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children:[
                                                                                Container(
                                                                                  decoration: BoxDecoration(
                                                                                    image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl),
                                                                                        fit: BoxFit.cover),
                                                                                    borderRadius: BorderRadius.circular(2),
                                                                                  ),
                                                                                  width: 700,
                                                                                  height: 500,
                                                                                ),
                                                                                MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].name,
                                                                                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 24, color: Colors.red, fontFamily: 'Montserrat-Medium'))),
                                                                                SizedBox(height: 5,),
                                                                                // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                                                                MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesPrices[0].price.toString(),
                                                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.red, fontFamily: 'Montserrat-Regular'),),),
                                                                                SizedBox(height: 5,),
                                                                                // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                                                                MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].portionWeightGrams.toStringAsFixed(0) + ' г',
                                                                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black, fontFamily: 'Montserrat-Regular'),),),
                                                                              ]
                                                                          )
                                                                      )
                                                                  )
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child:  Container(
                                                        width: 60,
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color: Color(0xFFE86A44)),
                                                            color: Colors.red
                                                        ),
                                                        child: Icon(Icons.add, color: Colors.white,),
                                                      ),
                                                    ),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                ),
                                              ),
                                              // snapshot.data![groupIndex].items[index].count == 0 ?
                                              // Container(
                                              //     height: 30,
                                              //     width: 200,
                                              //     decoration: BoxDecoration(
                                              //       color: Color(0xFF2E2F36),
                                              //       borderRadius: BorderRadius.circular(10),
                                              //     ),
                                              //     child: InkWell(
                                              //       onTap: (){
                                              //         setState(() {
                                              //           snapshot.data![groupIndex].items[index].count += 1;
                                              //           num newSum = 0;
                                              //           snapshot.data![groupIndex].items.forEach((element) {
                                              //             if(element.count > 0){
                                              //               num ssum = element.count * element.itemSizes[0].itemSizesPrices[0].price;
                                              //               newSum += ssum;
                                              //             }
                                              //           });
                                              //           sumOrder = newSum;
                                              //           newOrder = snapshot.data!;
                                              //         });
                                              //       },
                                              //       child: Center(child: Text('в корзину', style: TextStyle(color: Colors.white,), textAlign: TextAlign.center,),),
                                              //     )
                                              // ) :
                                              // Container(
                                              //   height: 30,
                                              //   width: 200,
                                              //   padding: EdgeInsets.symmetric(horizontal: 3),
                                              //   decoration: BoxDecoration(
                                              //     color: Color(0xFF2E2F36),
                                              //     borderRadius: BorderRadius.circular(10),
                                              //   ),
                                              //   child: Row(
                                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              //     children: [
                                              //       InkWell(
                                              //         onTap: (){
                                              //           setState(() {
                                              //             snapshot.data![groupIndex].items[index].count -= 1;
                                              //             num newSum = 0;
                                              //             snapshot.data![groupIndex].items.forEach((element) {
                                              //               if(element.count > 0){
                                              //                 num ssum = element.count * element.itemSizes[0].itemSizesPrices[0].price;
                                              //                 newSum += ssum;
                                              //               }
                                              //             });
                                              //             sumOrder = newSum;
                                              //             newOrder = snapshot.data!;
                                              //           });
                                              //         },
                                              //         child: Icon(Icons.remove, color: Colors.white, size: 18,),
                                              //       ),
                                              //       Text(snapshot.data![groupIndex].items[index].count.toString(), style: TextStyle(color: Colors.white),),
                                              //       InkWell(
                                              //         onTap: (){
                                              //           setState(() {
                                              //             snapshot.data![groupIndex].items[index].count += 1;
                                              //             num newSum = 0;
                                              //             snapshot.data![groupIndex].items.forEach((element) {
                                              //               if(element.count > 0){
                                              //                 num ssum = element.count * element.itemSizes[0].itemSizesPrices[0].price;
                                              //                 newSum += ssum;
                                              //               }
                                              //             });
                                              //             sumOrder = newSum;
                                              //             newOrder = snapshot.data!;
                                              //           });
                                              //         },
                                              //         child: Icon(Icons.add, color: Colors.white, size: 18,),
                                              //       ),
                                              //     ],
                                              //   ),
                                              // )
                                            ],
                                          ),
                                        );
                                      }
                                  )
                                ],
                              );
                            }
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
