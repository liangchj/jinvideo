
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AKDanmakuTest extends StatefulWidget {
  const AKDanmakuTest({Key? key}) : super(key: key);

  @override
  State<AKDanmakuTest> createState() => _AKDanmakuTestState();
}

class _AKDanmakuTestState extends State<AKDanmakuTest> {
  var platform = const MethodChannel('JIN_DANMAKU_NATIVE_VIEW');

  Widget _ak() {
    return const AndroidView(viewType: "JIN_DANMAKU_NATIVE_VIEW",
      creationParams: {
        'danmakuUrl': "/storage/emulated/0/Android/data/com.xyoye.dandanplay/files/danmu/18778692/test_danmaku_data.json",
        "danmakuType": "AK"
      },
      creationParamsCodec: StandardMessageCodec(),
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
    );
  }
  void start() {
    Future.delayed(Duration(seconds: 2), () {
      platform.invokeMethod('startDanmaku');
    });
  }
  @override
  Widget build(BuildContext context) {
    start();
    return Scaffold(
      body: _ak(),
    );
  }
}
