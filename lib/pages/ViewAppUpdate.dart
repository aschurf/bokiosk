import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/LogController.dart';

Future<void> restartApplication() async {
  Directory tempDir = await getApplicationDocumentsDirectory();
  final path = tempDir.path + '/Kiosk/bokiosk.msix';

  try {
    // Запускаем приложение через PowerShell
    await Process.run(
      'powershell',
      ['Start-Process', path],
      runInShell: true,
    );
    print('Application launched successfully!');
    exit(0);
  } catch (e) {
    print('Failed to launch application: $e');
  }
}

class ViewAppUpdate extends StatefulWidget {
  String versionApp;
  Map versionDescription;
  ViewAppUpdate({super.key, required this.versionApp, required this.versionDescription});

  @override
  State<ViewAppUpdate> createState() => _ViewAppUpdateState();
}

class _ViewAppUpdateState extends State<ViewAppUpdate> {
  bool isLoading = false;
  bool isUpdated = false;
  bool isUpdatedRun = false;
  double progress = 0.0;

  Future<void> downloadAndInstallMsix() async {
    logStashSend("Загрузка обновления ПО ", "", "");
    String url = 'https://new.procob.io/kiosk/bokiosk.msix';
    Directory tempDir = await getApplicationDocumentsDirectory();
    final path = tempDir.path + '/Kiosk/bokiosk.msix';
    Dio dio = Dio();
    try {
      print('Downloading update...');
      await dio.download(url, path, onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
          setState(() {
            progress = received / total;
          });
        }
      });
      print('Download completed.');
      logStashSend("ПО загружено", "", "");
      isUpdatedRun = true;
      print('Installing update...');
      ProcessResult result = await Process.run(
        'powershell',
        ['Start-Process', 'powershell', '-ArgumentList', "'Add-AppxPackage -Path \"$path\"'", '-Verb', 'RunAs'],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        print('Installation succeeded!');
        logStashSend("ПО установка", "", "");
        isUpdated = true;
        await restartApplication();
      } else {
        print('Installation failed: ${result.stderr}');
        logStashSend("Установка ПО завершилась ошибкой ${result.stderr}", "", "");
      }
    } catch (e) {
      print('Error: $e');
      logStashSend("Установка ПО Ошибка $e", "", "");
    }
  }

  @override
  Widget build(BuildContext context) {
    List appDescriptions = widget.versionDescription['description'];
    return Scaffold(
      backgroundColor: Color(0xFF191917),
      body: Container(
        width: MediaQuery.of(context).size.width * 0.99,
        height: MediaQuery.of(context).size.height * 0.99,
        child: Center(
          child: isLoading == false ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                child: Image.asset('assets/images/logo2.png'),
              ),
              SizedBox(height: 100,),
              Text('Обновление приложения ${widget.versionApp}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold')),
              SizedBox(height: 100,),
              Container(
                width: 500,
                height: 500,
                child: ListView.builder(
                  itemCount: appDescriptions.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      title: Text(appDescriptions[index], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
                    );
                  },
                ),
              ),
              SizedBox(height: 50,),
              InkWell(
                onTap: (){
                  setState(() {
                    isLoading = true;
                  });
                  downloadAndInstallMsix();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  width: 400,
                  height: 80,
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
                    child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('начать обновление',
                        style: TextStyle(fontWeight: FontWeight.w200, fontSize: 18, color: Colors.white, fontFamily: 'Montserrat-Medium', shadows: [
                        ]))),
                  ),
                ),
              )
            ],
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 800,
                child: LinearProgressIndicator(value: progress),
              ),
              SizedBox(height: 20),
              Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-Regular')),
            ],
          ),
        ),
      ),
    );
  }
}
