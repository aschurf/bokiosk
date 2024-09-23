import 'dart:convert';
import 'dart:developer';

import 'package:bokiosk/models/MenuModel.dart';
import 'package:bokiosk/models/OrderDishesModel.dart';
import 'package:bokiosk/pages/AdminPage.dart';
import 'package:bokiosk/pages/OrderTypeSelect.dart';
import 'package:bokiosk/pages/PinCodePage.dart';
import 'package:bokiosk/pages/ViewOrder.dart';
import 'package:bokiosk/pages/WelcomePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../constants.dart';
import '../controllers/KkmServerController.dart';



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
  String menuId;
  int typeOrder;
  HomePage({Key? key, required this.menuId, required this.typeOrder}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  List<OrderDishesModel> orderDishes = [];

  Future<List<MenuModel>>? _listFuture;
  List<dynamic>? newOrder;
  num sumOrder = 0;
  num fullSumOrder = 0;

  ScrollController scrollController = ScrollController();
  late ListObserverController observerController;

  int visibleSection = 0;
  @override
  void initState() {
    super.initState();
    // initial load
    _listFuture = getMenus(widget.menuId, '7ae08cea-95e9-4136-a746-ed0fe8077770');
    startTimer();
    observerController = ListObserverController(controller: scrollController);

  }

  void stater (){
    setState(() {

    });
  }

  // late Timer _timer;
  int _start = 120;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    // _timer = new Timer.periodic(
    //   oneSec,
    //       (Timer timer) {
    //     print(_start);
    //     if (_start == 0) {
    //       setState(() {
    //         timer.cancel();
    //       });
    //       Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => WelcomePage()
    //           ));
    //     } else if(_start == 30) {
    //       showAlertDialogTimer();
    //       setState(() {
    //         _start--;
    //       });
    //     } else {
    //       setState(() {
    //         _start--;
    //       });
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
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
        // _timer.cancel();
      },
    );
    Widget continueButton = TextButton(
      child: Text("продолжить", style: TextStyle(fontSize: 30),),
      onPressed:  () {
        Navigator.pop(context);
        setState(() {
          _start = 120;
        });
        stater();
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

  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Отменить", style: TextStyle(fontSize: 30),),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Удалить", style: TextStyle(fontSize: 30),),
      onPressed:  () {
        orderDishes = [];
        fullSumOrder = 0;
        setState(() {

        });
        stater();
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomePage()
            ));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Удалить заказ?", style: TextStyle(fontSize: 50),),
      content: Text("Нажмите удалить, если хотите начать заново. Все блюда будут удалены из корзины.", style: TextStyle(fontSize: 30),),
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
      body: GestureDetector(
        onTap: (){
          _start = 120;
        },
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 5,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: MediaQuery.of(context).size.height * 0.99,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onDoubleTap: () async {
                              var kk = await GetDataKKT();
                              var js = json.decode(kk);
                              String code = "";
                              final conn = await MySQLConnection.createConnection(
                                host: mySqlServer,
                                port: 3306,
                                userName: "kiosk_user",
                                password: "Iehbr201010",
                                databaseName: "kiosk", // optional
                              );

                              await conn.connect();

                              var result = await conn.execute('SELECT * FROM shifts WHERE session_number = :sNumber and kkm_command = :command',
                                  {
                                    'sNumber': js['SessionNumber'],
                                    'command': 'OpenShift',
                                  });


                              print(result.numOfRows);

                              for (final re in result.rows) {
                                print('MySQL result');
                                code = re.colByName("shift_code")!;
                              }

                              await conn.close();

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PinCodePage(code: code)
                                  ));
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(left: 10),
                              child: Image.asset('assets/images/logo2.png'),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                          ),
                          Container(
                            width: 670,
                            child: Text(widget.typeOrder == 1 ?  'Заказ в зале' : 'Заказ с собой', style: TextStyle(fontFamily: 'Montserrat-ExtraBold', fontSize: 45, color: Colors.white),),
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                          ),
                          InkWell(
                            onTap: () async {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderTypeSelect()
                                  ));
                            },
                            child: Container(
                              width: 200,
                              height: 70,
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Изменить', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30,),
                      SizedBox(height: 30,),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.999,
                        height: 70,
                        child: FutureBuilder(
                            future: _listFuture,
                            builder: (context, snap){
                              if(snap.hasData){
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snap.data!.length,
                                  itemBuilder: (context, ind){
                                    return InkWell(
                                      onTap: (){
                                        visibleSection = ind;
                                        setState(() {

                                        });
                                        observerController.animateTo(
                                          index: ind,
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.ease,
                                        );
                                      },
                                      child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            color: visibleSection == ind ? Color(0xFFD72314) : Color(0xFF42413D),
                                          ),
                                          child: Center(
                                            child: Text(snap.data![ind].name, style: TextStyle(fontFamily: 'Montserrat-ExtraBold', fontSize: visibleSection == ind ? 35 : 25, color: Colors.white),),
                                          )
                                      ),
                                    );
                                  },
                                );
                              }

                              return Container();
                            }
                        ),
                      ),
                      SizedBox(height: 30,),
                      FutureBuilder<List<MenuModel>>(
                        future: _listFuture,
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            return ListViewObserver(
                              controller: observerController,
                              onObserve: (resultMap) {
                                final model = resultMap;
                                // Выводит первый индекс элемента, который в данный момент отображается
                                print ( 'firstChild.index -- ${model.firstChild?.index}' );
                                // Выводит все индексы элементов, которые в данный момент отображаются
                                print ( 'displaying -- ${model.displayingChildIndexList}' );
                                // visibleSection = model.firstChild!.index;
                                // setState(() {
                                //
                                // });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.999,
                                height: MediaQuery.of(context).size.height * 0.8,
                                child: ListView.builder(
                                  // physics: const NeverScrollableScrollPhysics(),
                                  // shrinkWrap: true,
                                    controller: scrollController,
                                    itemCount: snapshot.data!.length,
                                    padding: EdgeInsets.only(bottom: 10),
                                    itemBuilder: (context, groupIndex){
                                      return Column(
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.99,
                                            child: Text(snapshot.data![groupIndex].name, style: TextStyle(fontFamily: 'Montserrat-ExtraBold', fontSize: 45, color: Colors.white),),
                                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
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
                                                                              snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers.length > 0 ? Text('Дополнительно',
                                                                                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 32, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Bold', shadows: [
                                                                                  ])) : Container(),
                                                                              snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers.length > 0 ?  SizedBox(height: 30,) : Container(),
                                                                              snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers.length > 0 ?  Container(
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
                                                                              ) : Container()
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
                                                                          if(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers.length > 0){
                                                                            snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems.forEach((element){
                                                                              setState((){
                                                                                if(element.isChecked){
                                                                                  element.isChecked = false;
                                                                                  dopPosSum -= element.enuItemSizeModifiersItemPrice[0].price;
                                                                                }
                                                                                dishCounter = 1;
                                                                              });
                                                                            });
                                                                          }
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
                                                                                    snapshot.data![groupIndex].items[index].stopList == false ? InkWell(
                                                                                      onTap: (){
                                                                                        List<OrderDishesModifiersModel> modifiersModel = [];
                                                                                        if(snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers.length > 0){
                                                                                          snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems.forEach((element){
                                                                                            if(element.isChecked){
                                                                                              modifiersModel.add(OrderDishesModifiersModel(
                                                                                                  name: element.name,
                                                                                                  id: element.itemId,
                                                                                                  price: element.enuItemSizeModifiersItemPrice[0].price));
                                                                                            }
                                                                                          });
                                                                                        }
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

                                                                                        if( snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers.length > 0){
                                                                                          snapshot.data![groupIndex].items[index].itemSizes[0].itemSizesModifiers[0].menuItemSizeModifiersItems.forEach((element){
                                                                                            setState((){
                                                                                              if(element.isChecked){
                                                                                                element.isChecked = false;
                                                                                                dopPosSum -= element.enuItemSizeModifiersItemPrice[0].price;
                                                                                              }
                                                                                              dishCounter = 1;
                                                                                            });
                                                                                          });
                                                                                        }

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
                                                                                                color: Colors.black12,
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
                                                                                    ) : Container(),
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
                                                            image: snapshot.data![groupIndex].items[index].stopList ? DecorationImage(image: CachedNetworkImageProvider(snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl),
                                                                fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation)) : DecorationImage(image: CachedNetworkImageProvider(snapshot.data![groupIndex].items[index].itemSizes[0].buttonImageUrl),
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
                                                                snapshot.data![groupIndex].items[index].stopList ? MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Будет позже',
                                                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30, color: Colors.red, fontFamily: 'Montserrat-ExtraBold', shadows: [
                                                                      Shadow(
                                                                        offset: Offset(1, 1),
                                                                        blurRadius: 5.0,
                                                                        color: Color.fromARGB(255, 0, 0, 0),
                                                                      ),
                                                                    ]))) : Container(),
                                                                SizedBox(height: 2,),
                                                                // Text(snapshot.data![index]['name'].toString(), style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14, color: Colors.white)),
                                                                MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text(snapshot.data![groupIndex].items[index].name,
                                                                    style: TextStyle(fontWeight: FontWeight.w200, fontSize: 25, color: Colors.white, fontFamily: 'Montserrat-ExtraBold', shadows: [
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
                                ),
                              )
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
              bottom: 130,
              right: 0,
              child: InkWell(
                onTap: (){
                  showAlertDialog(context);
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
            ) : Container(),
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
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewOrder(orderDishes: orderDishes, typeOrder: widget.typeOrder,)
                              )).then((value){
                            final data = value as Map<String, Object>;
                            print(data);
                            setState(() {
                              orderDishes = (data['dishesOrder'] as List<OrderDishesModel>?)!;
                              fullSumOrder = 0;
                            });
                            orderDishes.forEach((elementOrder){
                              fullSumOrder += elementOrder.price * elementOrder.dishCount;
                              elementOrder.modifiers.forEach((modifierElement){
                                fullSumOrder += modifierElement.price * elementOrder.dishCount;
                              });
                            });

                            stater();
                            setState(() {

                            });
                          });
                        },
                        child: Container(
                          width: 400,
                          height: 100,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Color(0xFFD72314)),
                            color: Color(0xFFD72314),
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
                            child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('корзина',
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 55, color: Colors.white, fontFamily: 'Montserrat-ExtraLight'),),),
                          ),
                        ),
                      )
                    ],
                  )
              ),
            ) : Container()
          ],
        ),
      )
    );
  }
}
