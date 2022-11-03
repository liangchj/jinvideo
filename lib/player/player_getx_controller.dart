
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jinvideo/db/cache_const.dart';
import 'package:jinvideo/db/mmkv_cache.dart';

import 'player_config.dart';
import 'player_params.dart';

class PlayerGetxController extends GetxController {
  late PlayerParams playerParams;
  late IPlayerMethod playerMethod;

  /// 是否可以改变全屏状态（默认进去全屏播放时不能修改 进入/退出全屏）
  bool canChangeFullScreenState = true;

  @override
  void onInit() {
    super.onInit();
    print("VideoPlayerController 初始化");
    playerParams = PlayerParams();
  }

  @override
  void onClose() {

    print("VideoPlayerController 销毁");
    playerMethod.onDisposePlayer();
    super.onClose();
  }

  /// 设置视频信息
  void setVideoInfo({required String videoUrl,
    String? cover,
    bool? autoPlay,
    bool? looping,
    double? aspectRatio}) {
    playerParams.videoUrl = videoUrl;
    if (cover != null) {
      playerParams.cover = cover;
    }
    if (autoPlay != null) {
      playerParams.autoPlay = autoPlay;
    }
    if (looping != null) {
      playerParams.looping = looping;
    }
    if (aspectRatio != null) {
      playerParams.aspectRatio = aspectRatio;
    }
    playerParams.danmakuUrl = DanmakuMMKVCache.getInstance().getString(CacheConst.cachePrev + videoUrl) ?? "";
    if (playerParams.danmakuUrl != null && playerParams.danmakuUrl!.isNotEmpty) {
      _createDanmakuWidget();
    }
  }

  /// 播放器初始化
  void initPlayer(IPlayerMethod method) {
    playerMethod = method;
    playerMethod.onInitPlayer().then((value) {});
  }

  /// 销毁播放器
  Future<void> disposePlayer() async {
    await playerMethod.onDisposePlayer();
  }

  /// 修改播放地址
  void changeVideoUrl(String newVideoUrl)  {
    if (playerParams.videoUrl == newVideoUrl) {
      return;
    }
    playerParams.videoUrl = newVideoUrl;
    playerMethod.changeVideoUrl(autoPlay: true);
    playerParams.danmakuUI = null;
    if (playerParams.showDanmaku) {
      _createDanmakuWidget();
      startDanmaku(playerParams.positionDuration);
    }

  }

  /// 更新视频状态
  void updateVideoState(VideoPlayerInfo value) {
    playerParams.hasError = false;
    playerParams.errorWidget = null;
    playerParams.isInitialized = value.isInitialized; // 记录初始化状态
    playerParams.duration = value.duration; // 记录视频时长
    playerParams.positionDuration = value.positionDuration; // 记录当前播放位置
    playerParams.isPlaying = value.isPlaying; // 记录当前是否播放
    playerParams.bufferedDurationRange.clear();
    playerParams.bufferedDurationRange.addAll(value.bufferedDurationRange);
    playerParams.isFinished = value.isFinished;
    update(["videoHasError", "playProgress", "positionDuration", "duration"]);
  }

  /// 初始化
  Future<void> initialize() async {
    playerMethod.initialize().then((value) {
      playerParams.isInitialized = true;
    });
  }

  /// 播放
  Future<void> play() async {
    playerMethod.play().then((value) {
      playerParams.isPlaying = true;

      // showDanmaKu();
      update(['playPauseBtn']);
    });
    if (playerParams.danmakuUI == null) {
      _createDanmakuWidget();
      startDanmaku(playerParams.positionDuration);
    } else {
      startDanmaku(playerParams.positionDuration);
    }
  }

  /// 暂停
  Future<void> pause() async {
    playerMethod.pause().then((value) {
      playerParams.isPlaying = false;
      update(['playPauseBtn']);
      pauseDanmaKu();
    });
  }

  /// 视频跳转
  Future<void> seekTo(Duration position) async {
    playerMethod.seekTo(position).then((value) {
      danmakuSeekTo();
    });
  }

  /// 暂停或播放
  Future<void> playOrPause() async {
    if (playerParams.isFinished) {
      await seekTo(Duration.zero);
    }
    if (playerParams.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// 改变顶部和底部UI显示状态
  void changeShowTopAndBottomUIState(bool flag) {
    bool haveChange = playerParams.showTopUI != flag && playerParams.showBottomUI != flag;
    playerParams.showTopUI = flag;
    playerParams.showBottomUI = flag;
    if (haveChange) {
      update(["haveUIShow", "topBarUI", "bottomBarUI"]);
    }
  }

  /// 改变顶部UI显示状态
  void changeShowTopUIState(bool flag) {
    bool haveChange = playerParams.showTopUI != flag;
    playerParams.showTopUI = flag;
    if (haveChange) {
      update(["haveUIShow", "topBarUI"]);
    }
  }
  /// 改变中间UI显示状态
  void changeShowCenterUIState(bool flag) {
    bool haveChange = playerParams.showCenterUI != flag;
    playerParams.showCenterUI = flag;
    if (haveChange) {
      update(["haveUIShow", "centerUI"]);
    }
  }
  /// 改变底部UI显示状态
  void changeShowBottomUIState(bool flag) {
    bool haveChange = playerParams.showBottomUI != flag;
    playerParams.showBottomUI = flag;
    if (haveChange) {
      update(["haveUIShow", "bottomBarUI"]);
    }
  }
  /// 改变弹幕设置UI显示状态
  void changeShowDanmakuSettingState(bool flag) {
    bool haveChange = playerParams.showDanmakuSetting != flag;
    playerParams.showDanmakuSetting = flag;
    if (haveChange) {
      update(["haveUIShow", "danmakuSetting"]);
    }
  }
  /// 改变弹幕源UI显示状态
  void changeShowDanmakuSourceSettingState(bool flag) {
    bool haveChange = playerParams.showDanmakuSourceSetting != flag;
    playerParams.showDanmakuSourceSetting = flag;
    if (haveChange) {
      update(["haveUIShow", "danmakuSourceSetting"]);
    }
  }
  /// 改变播放速度UI显示状态
  void changeShowPlaySpeedSettingState(bool flag) {
    bool haveChange = playerParams.showPlaySpeedSetting != flag;
    playerParams.showPlaySpeedSetting = flag;
    if (haveChange) {
      update(["haveUIShow", "playSpeedSetting"]);
    }
  }
  /// 改变视频章节UI显示状态
  void changeShowVideoChapterListState(bool flag) {
    bool haveChange = playerParams.showVideoChapterList != flag;
    playerParams.showVideoChapterList = flag;
    if (haveChange) {
      update(["haveUIShow", "videoChapterList"]);
    }
  }
  /// 是否有UI显示
  bool haveUIShow() {
    return playerParams.showTopUI ||
        playerParams.showCenterUI  ||
        playerParams.showBottomUI ||
        playerParams.showDanmakuSetting ||
        playerParams.showDanmakuSourceSetting ||
        playerParams.showPlaySpeedSetting  ||
        playerParams.showVideoChapterList ;
  }

  /// 隐藏所有UI
  void hideAllUI() {
    List<String> updateIds = ["haveUIShow"];
    if (playerParams.showTopUI) {
      updateIds.add("topBarUI");
    }
    if (playerParams.showCenterUI) {
      updateIds.add("centerUI");
    }
    if (playerParams.showBottomUI) {
      updateIds.add("bottomBarUI");
    }
    if (playerParams.showDanmakuSetting) {
      updateIds.add("danmakuSetting");
    }
    if (playerParams.showDanmakuSourceSetting) {
      updateIds.add("danmakuSourceSetting");
    }
    if (playerParams.showPlaySpeedSetting) {
      updateIds.add("playSpeedSetting");
    }
    if (playerParams.showVideoChapterList) {
      updateIds.add("videoChapterList");
    }

    playerParams.showTopUI = false;
    playerParams.showCenterUI = false;
    playerParams.showBottomUI = false;
    playerParams.showDanmakuSetting = false;
    playerParams.showDanmakuSourceSetting = false;
    playerParams.showPlaySpeedSetting = false;
    playerParams.showVideoChapterList = false;
    update(updateIds);
  }


  // 弹幕控制
  // 创建弹幕
  void _createDanmakuWidget() {
    if (playerParams.danmakuUrl == null || playerParams.danmakuUrl!.trim().isEmpty) {
      return;
    }
    var file = File(playerParams.danmakuUrl!.trim());
    if (!file.existsSync()) {
      return;
    }
    if (playerParams.showDanmaku && playerParams.danmakuUI == null) {
      try {
        playerParams.danmakuUI =
            /*AndroidView(
              key: ValueKey(playerParams.danmakuUrl),
              viewType: "JIN_DANMAKU_NATIVE_VIEW",
              creationParams: {
                'danmakuUrl': "/storage/emulated/0/Android/data/com.xyoye.dandanplay/files/danmu/18778692/test_danmaku_data.json",
                "danmakuType": "AK"
              },
              creationParamsCodec: StandardMessageCodec(),
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            );*/
            AndroidView(
              // key: ValueKey(playerParams.danmakuUrl),
              viewType: "JIN_DANMAKU_NATIVE_VIEW",
              creationParams: {'danmakuUrl': playerParams.danmakuUrl!.trim(),
                "danmakuType": "BILI",
                "isShowFPS": false,
                "isShowCache": false,
                "isStart": playerParams.isPlaying,
                "fixedTopDanmakuVisibility": playerParams.fixedTopDanmakuVisibility,
                "fixedBottomDanmakuVisibility": playerParams.fixedBottomDanmakuVisibility,
                "rollDanmakuVisibility": playerParams.rollDanmakuVisibility,
                "specialDanmakuVisibility": playerParams.specialDanmakuVisibility,
                "duplicateMergingEnabled": playerParams.duplicateMergingEnabled,
                "colorsDanmakuVisibility": playerParams.colorsDanmakuVisibility,
              },
              creationParamsCodec: const StandardMessageCodec(),
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            );
        playerParams.danmakuUICreateSuccess = true;
        update(["showDanmaku"]);
      } catch (e) {
        playerParams.danmakuUICreateSuccess = false;
      }
    }
  }

  /// 启动弹幕
  Future<void> startDanmaku(Duration duration) async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('startDanmaku', {'time': duration.inMilliseconds.toString()});
    }
  }

  /// 暂停弹幕
  Future<void> pauseDanmaKu() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('pauseDanmaKu');
    }
  }

  /// 显示弹幕
  Future<void> showDanmaKu() async {
    if (!playerParams.showDanmaku) {
      playerParams.showDanmaku = true;
      // update(["showDanmaku"]);
    }
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      playerParams.platform.invokeMethod('showDanmaKu').then((value) {
        if (playerParams.isPlaying) {
          startDanmaku(playerParams.positionDuration);
        }
      });
    } else {
      _createDanmakuWidget();
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        if (playerParams.isPlaying) {
          startDanmaku(playerParams.positionDuration);
        } else {
          pauseDanmaKu();
        }
      });
    }
  }

  /// 隐藏弹幕
  Future<void> hideDanmaKu() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('hideDanmaKu');
    }
  }

  /// 弹幕跳转
  Future<void> danmakuSeekTo({Duration? duration}) async {
    var to = (duration ?? playerParams.positionDuration).inMilliseconds.toString();
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      var result = await playerParams.platform.invokeMethod(
          'danmaKuSeekTo', {'time': to});
      print("跳转弹幕状态：$result");
      if (result && !playerParams.isPlaying) {
        // 因弹幕引擎在跳转时重新绘制出现，因此跳转后延迟300毫秒在停止
        Future.delayed(const Duration(milliseconds: 300)).then((value) => pauseDanmaKu());
      }
    }
  }

  /// 设置弹幕滚动速度
  Future<void> setDanmakuSpeed() async {
    double speedRatio = playerParams.playSpeed * PlayerConfig.danmakuSpeedList[playerParams.danmakuSpeed];
    print("计算后的弹幕速度系数: $speedRatio");
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('setScrollSpeedFactor', {'speedRatio': speedRatio});
    }
  }

  /// 设置弹幕字体大小
  Future<void> setDanmakuScaleTextSize() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('setDanmakuScaleTextSize', {'danmakuFontSize': playerParams.danmakuFontSize});
    }
  }

  /// 设置是否启用合并重复弹幕
  Future<void> setDuplicateMergingEnabled() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('setDuplicateMergingEnabled', {"flag": playerParams.duplicateMergingEnabled});
    }
  }

  /// 设置是否显示顶部固定弹幕
  Future<void> setFixedTopDanmakuVisibility() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('setFixedTopDanmakuVisibility', {"visible": playerParams.fixedTopDanmakuVisibility});
    }
  }

  /// 设置是否显示滚动弹幕
  Future<void> setFixedBottomDanmakuVisibility() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('setFixedBottomDanmakuVisibility', {"visible": playerParams.fixedBottomDanmakuVisibility});
    }
  }
  /// 设置是否显示滚动弹幕
  Future<void> setRollDanmakuVisibility() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      print("修改滚动弹幕显示:${playerParams.rollDanmakuVisibility}");
      var r = await playerParams.platform.invokeMethod('setRollDanmakuVisibility', {"visible": playerParams.rollDanmakuVisibility});
      print("修改滚动弹幕显示:$r");
    }
  }

  /// 设置是否显示特殊弹幕
  Future<void> setSpecialDanmakuVisibility() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('setSpecialDanmakuVisibility', {"visible": playerParams.specialDanmakuVisibility});
    }
  }

  /// 是否显示彩色弹幕
  Future<void> setColorsDanmakuVisibility() async {
    if (playerParams.danmakuUI != null && playerParams.danmakuUICreateSuccess) {
      return await playerParams.platform.invokeMethod('setColorsDanmakuVisibility', {"visible": playerParams.colorsDanmakuVisibility});
    }
  }


}