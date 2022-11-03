
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinvideo/player/player_view.dart';
import 'package:jinvideo/utils/overla_manager.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  OverlayEntry? _overlayEntry;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    /*WidgetsBinding.instance.addPostFrameCallback((callback) {
      //创建一个OverlayEntry对象
      _overlayEntry = OverlayEntry(builder: (context) {
        //外层使用Positioned进行定位,控制在Overlay中的位置
        return const Positioned(child: Center(child: Text("测试"),));
        // return Positioned.fill(
        //     child: PlayerView(videoUrl: widget.videoUrl, fullScreenPlay: false));
      });
      //往Overlay中插入插入OverlayEntry
      Overlay.of(context)?.insert(_overlayEntry!);
    });*/
    /*WidgetsBinding.instance.addPostFrameCallback((callback) {
      OverlayManager.initInstance(context).showOverlay(true, widget: const Positioned(child: Center(child: Text("测试"),)));
    });*/
    Future.delayed(Duration(seconds: 2)).then((value) {
      //创建一个OverlayEntry对象
      _overlayEntry = OverlayEntry(builder: (context) {
        //外层使用Positioned进行定位,控制在Overlay中的位置
        return const Positioned(child: Center(child: Text("测试"),));
        // return Positioned.fill(
        //     child: PlayerView(videoUrl: widget.videoUrl, fullScreenPlay: false));
      });
      //往Overlay中插入插入OverlayEntry
      Overlay.of(context)?.insert(_overlayEntry!);
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    // OverlayManager.getInstance().showOverlay(false);
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
              // child: PlayerView(videoUrl: widget.videoUrl, ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text("视频下的文字", style: TextStyle(color: Colors.red, fontSize: 50),)),
          ]
      ),
    );
  }
}
