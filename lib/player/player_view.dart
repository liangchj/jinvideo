import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jinvideo/player/player_getx_controller.dart';

import '../widget/ui/player_ui.dart';
import 'player_params.dart';
import 'video_player_method.dart';

class PlayerView extends StatefulWidget {
  const PlayerView(
      {Key? key,
        required this.videoUrl,
        this.cover,
        this.autoPlay,
        this.looping,
        this.aspectRatio,
        this.fullScreenPlay = true,
        this.playerType = PlayerType.flutterPlayer})
      : super(key: key);
  final String videoUrl;
  final String? cover;
  final bool? autoPlay;
  final bool? looping;
  final double? aspectRatio;
  final bool fullScreenPlay;
  final PlayerType playerType;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late PlayerGetxController _playerGetxController;
  @override
  void initState() {
    super.initState();
    _playerGetxController = Get.put(PlayerGetxController());
    _playerGetxController.canChangeFullScreenState = !widget.fullScreenPlay;
    _playerGetxController.setVideoInfo(
        videoUrl: widget.videoUrl,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: widget.aspectRatio);
    IPlayerMethod playerMethod = VideoPlayerMethod(_playerGetxController);
    _playerGetxController.initPlayer(playerMethod);
    if (widget.fullScreenPlay) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
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
    return OrientationBuilder(builder: (context, orientation) {
      return WillPopScope(
        onWillPop: () async {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
          return Future(() => true);
        },
        child: SafeArea(
          child: Center(
            child: Stack(
              children: [
                Center(
                  child: _buildHorizontalScreenPlayerView(),
                ),
                GetBuilder<PlayerGetxController>(
                    id: "playerView",
                    builder: (_) {
                      return _.playerParams.danmakuUI ?? Container();
                    }),
                const Positioned.fill(child: PlayerUI(),),
              ],
            ),
          ),
        ),
      );
    }
    );
  }

  /// 全屏播放view（横屏）
  Widget _buildHorizontalScreenPlayerView() {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    double min = 0, max = 0;
    if (width > height) {
      min = height;
      max = width;
    } else {
      min = width;
      max = height;
    }
    double playerHeight = min;
    double playerWidth = _playerGetxController.playerParams.aspectRatio * min;
    if (playerWidth > max) {
      playerWidth = max;
      playerHeight =
          playerWidth / _playerGetxController.playerParams.aspectRatio;
    }
    return SizedBox(
        width: playerWidth,
        height: playerHeight,
        child: _playerGetxController.playerParams.videoPlayerView);
  }
}
