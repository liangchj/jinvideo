
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class DanPage extends StatefulWidget {
  const DanPage({Key? key}) : super(key: key);

  @override
  State<DanPage> createState() => _DanPageState();
}

class _DanPageState extends State<DanPage> {
  var platform = const MethodChannel('JIN_DANMAKU_NATIVE_VIEW');
  late final Widget danmaku;

  @override
  void initState() {
    super.initState();
    danmaku = _an();
  }

  Widget _an() {
    return const AndroidView(viewType: "JIN_DANMAKU_NATIVE_VIEW",
      creationParams: {
        'danmakuUrl': "/storage/emulated/0/Android/data/com.xyoye.dandanplay/files/danmu/18778692/9b2d5b753ea3beeef4700031c0c8fb56_720p.xml",
        "danmakuType": "BILI",
        "isShowFPS": true,
        "isShowCache": true,
        "colorsDanmakuVisibility": true
      },
      creationParamsCodec: StandardMessageCodec(),
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
    );
  }
  bool full = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          full ? const HzPage() : const VerPage(),
          danmaku
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            full = !full;
          });
        },
        tooltip: 'getVideo',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class VerPage extends StatefulWidget {
  const VerPage({Key? key}) : super(key: key);

  @override
  State<VerPage> createState() => _VerPageState();
}

class _VerPageState extends State<VerPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("竖屏", style: TextStyle(fontSize: 30, color: Colors.red),),
    );
  }
}

class HzPage extends StatefulWidget {
  const HzPage({Key? key}) : super(key: key);

  @override
  State<HzPage> createState() => _HzPageState();
}

class _HzPageState extends State<HzPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("横屏", style: TextStyle(fontSize: 30, color: Colors.red),),
    );
  }
}
