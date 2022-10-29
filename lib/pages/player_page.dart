
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinvideo/player/player_view.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print("创建UI build PlayerPage");
    return Scaffold(
      /*appBar: AppBar(
        title: const Text("在线播放视频"),
      ),*/
      body: Column(
          children: [
            Container(
              color: Colors.yellow,
              height: MediaQuery.of(context).size.width * (9 / 16),
              child: PlayerView(videoUrl: widget.videoUrl, ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text("视频下的文字", style: TextStyle(color: Colors.red, fontSize: 50),)),
          ]
      ),
    );
  }
}
