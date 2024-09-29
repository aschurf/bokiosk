import 'package:bokiosk/pages/AdminPage.dart';
import 'package:flutter/material.dart';

import '../controllers/PaymentsController.dart';
import 'WelcomePage.dart';

class ReturnPayPage extends StatefulWidget {
  int checkNumber;
  ReturnPayPage({Key? key, required this.checkNumber}) : super(key: key);

  @override
  State<ReturnPayPage> createState() => _ReturnPayPageState();
}

class _ReturnPayPageState extends State<ReturnPayPage> {

  String errorMsg = "";
  String successMsg  = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    returnPayByCheckNumber(widget.checkNumber).then((res){
      setState(() {
        successMsg = "Возврат успешно завершен. Деньги поступят на карту.";
      });
    }).catchError((error){
      print(error);
      setState(() {
        errorMsg = error;
      });
    });
  }


  void toAdmin(){
    Future((){
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AdminPage()
      ));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191917),
      body: Stack(
        children: [
          Positioned(
            top: 200,
            left: 240,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                image: DecorationImage(image: ExactAssetImage('assets/images/ekv.png'),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          errorMsg == "" && successMsg == "" ? Positioned(
            top: 700,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: 600,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                )
            ),
          ) : Container(),
          errorMsg == "" && successMsg == "" ?  Positioned(
            top: 900,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: 600,
                child: Center(
                  child: Text('Следуйте указаниям на терминале', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                )
            ),
          ) : Container(),
          errorMsg != "" ? Positioned(
            top: 900,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: 600,
                child: Center(
                  child: Text(errorMsg, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40, color: Colors.red, fontFamily: 'Montserrat-Regular'), textAlign: TextAlign.center,),
                )
            ),
          ) : Container(),
          successMsg != "" ?  Positioned(
            top: 900,
            left: 0,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.999,
                height: 600,
                child: Center(
                  child: Text(successMsg, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40, color: Colors.green, fontFamily: 'Montserrat-Regular'), textAlign: TextAlign.center,),
                )
            ),
          ) : Container(),
          successMsg != "" || errorMsg != ""  ? Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.999,
              height: MediaQuery.of(context).size.height * 0.07,
              color: Color(0xFF42413D),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminPage()
                          ),
                              (Route<dynamic> route) => false);
                    },
                    child: Container(
                      width: 580,
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
                          Text('вернуться', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: (){

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage()
                          ),
                              (Route<dynamic> route) => false);
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
                          Text('Завершить', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }
}
