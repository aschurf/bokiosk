import 'package:bokiosk/pages/HomePage.dart';
import 'package:bokiosk/pages/OrderTypeSelect.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);


  @override
  void initState() {
    super.initState();
    final playable = Playlist(
      [
        Media('asset:///assets/videos/1v3.mp4'),
        Media('asset:///assets/videos/2v3.mp4'),
        Media('asset:///assets/videos/4v3.mp4'),
      ],
    );

    player.open(playable);
    st();

  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void st() async {
    await player.setPlaylistMode(PlaylistMode.loop);
    await player.setVolume(0.0);
    await player.setShuffle(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => OrderTypeSelect(),
            transitionDuration: Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          ),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 1.1,
                height: MediaQuery.of(context).size.height * 1.2,
                child: Video(controller: controller, controls: NoVideoControls,),
              ),
            ),
            Positioned(
              top: 1400,
              left: 200,
              child: Container(
                  width: 700,
                  height: 150,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 8,
                        blurRadius: 20,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1), child: Text('Закажите здесь',
                        style: TextStyle(fontWeight: FontWeight.w200, fontSize: 70, color: Color(0xFFD6D5D1), fontFamily: 'Montserrat-ExtraBold', shadows: [
                        ]))),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
