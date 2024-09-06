import 'dart:convert';
import 'dart:developer';

import 'package:bokiosk/models/MenuModel.dart';
import 'package:bokiosk/models/OrderDishesModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';



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

  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  List<OrderDishesModel> orderDishes = [];

  Future<List<MenuModel>>? _listFuture;
  List<dynamic>? newOrder;
  num sumOrder = 0;
  num fullSumOrder = 0;
  @override
  void initState() {
    super.initState();
    // initial load
    _listFuture = getMenus('31481', '7ae08cea-95e9-4136-a746-ed0fe8077770');
    // player.open(Media('https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'));
  }

  void stater (){
    setState(() {

    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191917),
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
                                    child: Text(snapshot.data![groupIndex].name, style: TextStyle(fontFamily: 'Montserrat-Regular', fontSize: 24, color: Colors.white),),
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                  ),
                                  GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 450,
                                          childAspectRatio: 3 / 2,
                                          crossAxisSpacing: 10,
                                          mainAxisExtent: 382,
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
                                        //Модальное окно с описанием блюда и выбором модификаторов
                                        int dishCounter = 1;
                                        num dopPosSum = 0 ;
                                        return InkWell(
                                          onTap: (){
                                            //TODO:модальное окно с описанием блюда и модификаторами
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (context, setState){
                                                      return Scaffold(
                                                        backgroundColor: Color(0xFF191917),
                                                        body: Stack(
                                                          children: [
                                                            Positioned(
                                                              top: 0,
                                                              left: 0,
                                                              child: Container(
                                                                width: MediaQuery.of(context).size.width * 0.999,
                                                                height: 700,
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl),
                                                                      fit: BoxFit.cover),
                                                                  borderRadius: BorderRadius.circular(12),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Color(0xFF302F2D),
                                                                      spreadRadius: 8,
                                                                      blurRadius: 20,
                                                                      offset: Offset(0, 0), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            //Дополнительные модификаторы для блюда
                                                            Positioned(
                                                              top: 720,
                                                              left: 0,
                                                              child: Container(
                                                                  width: MediaQuery.of(context).size.width * 0.999,
                                                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                                                  child: Column(
                                                                    children: [
                                                                      MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].description,
                                                                          style: TextStyle(fontWeight: FontWeight.w200, fontSize: 32, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraLight', shadows: [
                                                                          ]))),
                                                                      SizedBox(height: 30,),
                                                                      Text('Дополнительно',
                                                                          style: TextStyle(fontWeight: FontWeight.w200, fontSize: 32, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Bold', shadows: [
                                                                          ])),
                                                                      SizedBox(height: 30,),
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width * 0.99,
                                                                        height: 650,
                                                                        child: GridView.builder(
                                                                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                                              maxCrossAxisExtent: 220,
                                                                              childAspectRatio: 4 / 3,
                                                                              crossAxisSpacing: 10,
                                                                              mainAxisExtent: 270,
                                                                              mainAxisSpacing: 10),
                                                                          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                          //   crossAxisCount: 3,
                                                                          //   crossAxisSpacing: 10,
                                                                          //   mainAxisExtent: 256,
                                                                          // ),
                                                                          itemCount: snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems.length,
                                                                          itemBuilder: (context, modifierIndex){
                                                                            return InkWell(
                                                                              onTap: (){
                                                                                setState(() {
                                                                                  snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].isChecked = !snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].isChecked;
                                                                                  if(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].isChecked){
                                                                                    dopPosSum += snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].enuItemSizeModifiersItemPrice[0].price;
                                                                                  } else {
                                                                                    dopPosSum -= snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].enuItemSizeModifiersItemPrice[0].price;
                                                                                  }
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                                width: 200,
                                                                                height: 300,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  color: snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].isChecked ? Color(0xFF54534F) : Color(0xFF242424),
                                                                                ),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Container(
                                                                                        width: 150,
                                                                                        height: 150,
                                                                                        decoration: BoxDecoration(
                                                                                            image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].buttonImageUrl),
                                                                                                fit: BoxFit.cover),
                                                                                            borderRadius: BorderRadius.circular(12),
                                                                                            color: Colors.white
                                                                                        )
                                                                                    ),
                                                                                    Center(
                                                                                      child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].name,
                                                                                        style: TextStyle(fontWeight: FontWeight.w200, fontSize: 20, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraLight', shadows: [
                                                                                        ]), textAlign: TextAlign.center,)),
                                                                                    ),
                                                                                    Center(
                                                                                      child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems[modifierIndex].enuItemSizeModifiersItemPrice[0].price.toString() + ' руб.',
                                                                                        style: TextStyle(fontWeight: FontWeight.w200, fontSize: 20, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraLight', shadows: [
                                                                                        ]), textAlign: TextAlign.center,)),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      )
                                                                    ],
                                                                  )
                                                              ),
                                                            ),
                                                            //TODO: закрыть окно описания товара
                                                            Positioned(
                                                              bottom: 200,
                                                              right: 0,
                                                              child: InkWell(
                                                                onTap: (){
                                                                  snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems.forEach((element){
                                                                    setState((){
                                                                      if(element.isChecked){
                                                                        element.isChecked = false;
                                                                        dopPosSum -= element.enuItemSizeModifiersItemPrice[0].price;
                                                                      }
                                                                      dishCounter = 1;
                                                                    });
                                                                  });
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Container(
                                                                  width: 80,
                                                                  height: 80,
                                                                  decoration: BoxDecoration(
                                                                    color: Color(0xFF302F2D),
                                                                  ),
                                                                  child: Icon(Icons.close, color: Colors.white, size: 50,),
                                                                ),
                                                              ),
                                                            ),
                                                            //TODO: инструменты в модальном окне для добавления товара в корзину
                                                            Positioned(
                                                              bottom: 0,
                                                              left: 0,
                                                              child: Container(
                                                                  width: MediaQuery.of(context).size.width * 0.999,
                                                                  height: 200,
                                                                  decoration: BoxDecoration(
                                                                    color: Color(0xFF42413D),
                                                                  ),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                                                            Row(
                                                                              children: [
                                                                                MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].name,
                                                                                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 51, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Medium', shadows: [
                                                                                    ]))),
                                                                                SizedBox(width: 10,),
                                                                                MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].portionWeightGrams.toStringAsFixed(0) + ' г',
                                                                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular'),),),
                                                                              ],
                                                                            ),
                                                                            MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text((snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesPrices[0].price * dishCounter + dopPosSum * dishCounter).toString() + ' ₽',
                                                                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 32, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular'),),),
                                                                          ],
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        ),
                                                                        SizedBox(height: 20,),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: (){
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Container(
                                                                                width: 400,
                                                                                height: 100,
                                                                                padding: EdgeInsets.symmetric(horizontal: 20),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(15),
                                                                                  border: Border.all(color: Color(0xFF54534F)),
                                                                                  color: Color(0xFF54534F),
                                                                                  boxShadow: [
                                                                                    BoxShadow(
                                                                                      color: Color(0xFF54534F),
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
                                                                                          if(dishCounter > 1){
                                                                                            dishCounter--;
                                                                                          }
                                                                                        });
                                                                                      },
                                                                                      child: Icon(Icons.remove, color: Colors.white, size: 65,),
                                                                                    ),
                                                                                    Text(dishCounter.toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 55, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                                                                                    InkWell(
                                                                                      onTap: (){
                                                                                        setState(() {
                                                                                          dishCounter++!;
                                                                                        });
                                                                                      },
                                                                                      child: Icon(Icons.add, color: Color(0xFFD6D5D1), size: 65,),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: (){
                                                                                List<OrderDishesModifiersModel> modifiersModel = [];
                                                                                snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems.forEach((element){
                                                                                  if(element.isChecked){
                                                                                    modifiersModel.add(OrderDishesModifiersModel(
                                                                                        name: element.name,
                                                                                        id: element.itemId,
                                                                                        price: element.enuItemSizeModifiersItemPrice[0].price));
                                                                                  }
                                                                                });
                                                                                setState((){
                                                                                  orderDishes.add(OrderDishesModel(
                                                                                      name: snapshot.data![groupIndex].items[index].name,
                                                                                      id: snapshot.data![groupIndex].items[index].itemId,
                                                                                      price: snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesPrices[0].price,
                                                                                      dishCount: dishCounter,
                                                                                      imageUrl: snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl,
                                                                                      modifiers: modifiersModel));
                                                                                      fullSumOrder = 0;
                                                                                });

                                                                                snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems.forEach((element){
                                                                                  setState((){
                                                                                    if(element.isChecked){
                                                                                      element.isChecked = false;
                                                                                      dopPosSum -= element.enuItemSizeModifiersItemPrice[0].price;
                                                                                    }
                                                                                    dishCounter = 1;
                                                                                  });
                                                                                });
                                                                                Navigator.pop(context);

                                                                                orderDishes.forEach((elementOrder){
                                                                                  fullSumOrder += elementOrder.price * elementOrder.dishCount;
                                                                                  elementOrder.modifiers.forEach((modifierElement){
                                                                                    fullSumOrder += modifierElement.price * elementOrder.dishCount;
                                                                                  });
                                                                                });

                                                                                stater();
                                                                              },
                                                                              child: Container(
                                                                                  width: 600,
                                                                                  height: 100,
                                                                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                    border: Border.all(color: Color(0xFFD72314)),
                                                                                    color: Color(0xFFD72314),
                                                                                    boxShadow: [
                                                                                      BoxShadow(
                                                                                        color: Color(0xFFD72314),
                                                                                        spreadRadius: 2,
                                                                                        blurRadius: 10,
                                                                                        offset: Offset(0, 0), // changes position of shadow
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child: Center(
                                                                                    child: Text('Добавить', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 48, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraLight')),
                                                                                  )
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            height: 350,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Color(0xFF191917)),
                                              color: Color(0xFF191917),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xFF302F2D),
                                                  spreadRadius: 2,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 0), // changes position of shadow
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
                                                  height: 380,
                                                  width: 500,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl),
                                                        fit: BoxFit.cover),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(height: 2,),
                                                        // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].name,
                                                            style: TextStyle(fontWeight: FontWeight.w200, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                                                              Shadow(
                                                                offset: Offset(1, 1),
                                                                blurRadius: 5.0,
                                                                color: Color.fromARGB(255, 0, 0, 0),
                                                              ),
                                                            ]))),
                                                        SizedBox(height: 2,),
                                                        // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                                        MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesPrices[0].price.toString() + ' ₽',
                                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white, fontFamily: 'Montserrat-Regular'),),),
                                                        // SizedBox(height: 5,),
                                                        // // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                                        // MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].itemSizes[0].portionWeightGrams.toStringAsFixed(0) + ' г',
                                                        //   style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.black, fontFamily: 'Montserrat-Regular'),),),
                                                      ],
                                                    ),
                                                  ),
                                                ) : Container(),
                                              ],
                                            ),
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
          //TODO: продолжить оформление заказа
          orderDishes.length > 0 ? Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: MediaQuery.of(context).size.height * 0.07,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: Color(0xFF42413D),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(fullSumOrder.toString() + ' ₽',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 55, color: Colors.white, fontFamily: 'Montserrat-Regular'),),),
                  Container(
                    width: 400,
                    height: 100,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Color(0xFFD72314)),
                      color: Color(0xFFD72314),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD72314),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('корзина',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 55, color: Colors.white, fontFamily: 'Montserrat-ExtraLight'),),),
                    ),
                  )
                ],
              )
            ),
          ) : Container()
        ],
      ),
    );
  }
}
