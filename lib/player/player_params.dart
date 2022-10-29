import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinvideo/model/file_model.dart';

import 'player_config.dart';
import 'player_progress_bar.dart';

enum PlayerType { fijkplayer, flutterPlayer }

enum SourceType { net, asset }

/// 播放器参数
class PlayerParams {
  // 播放器
  Widget? videoPlayerView;
  String videoUrl = ""; // 视频播放路径
  String? cover; // 视频封面
  String? danmakuUrl; // 弹幕地址
  String? subtitlePath; // 字幕地址
  bool looping = PlayerConfig.looping; // 循环播放
  bool autoPlay = PlayerConfig.autoPlay;
  double aspectRatio = PlayerConfig.aspectRatio; // 播放器比例

  // 全屏播放（直接进入全屏播放，且只能进行全屏播放）
  bool fullScreenPlay = PlayerConfig.fullScreenPlay;

  // 全屏播放（全屏/非全屏转换状态）
  bool isFullScreen = false;

  // 视频信息
  bool hasError = false; // 有错误信息
  Widget? errorWidget; // 错误显示图标

  Duration duration = Duration.zero; // 总时长
  Duration positionDuration = Duration.zero; // 当前播放时长
  List<BufferedDurationRange> bufferedDurationRange = []; // 缓冲区间列表

  bool isInitialized = false; // 视频已初始化
  bool isPlaying = false; // 视频播放中
  bool beforeSeekIsPlaying = false; // 拖动进度时播放状态
  bool isBuffering = false; // 缓冲中
  bool isSeeking = false; // 进度跳转中
  bool isDragging = false; // 拖动中
  bool isFinished = false; // 播放结束

  // UI 部分
  // bool haveUIShow = false; // 有UI显示（除了弹幕UI）
  bool showTopUI = false; // 显示顶部UI
  bool showCenterUI = false; // 显示顶部UI
  bool showBottomUI = false; // 显示底部UI
  bool showDanmaku = true; // 显示弹幕UI
  bool showDanmakuSetting = false; // 显示弹幕设置
  bool showDanmakuSourceSetting = false; // 显示源设置
  bool showPlaySpeedSetting = false; // 显示播放速度设置
  bool showVideoChapterList = false; // 显示视频章节列表

  // 设置
  // 播放速度： ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '1.75x', '2.0x']
  double playSpeed = 1.0;

  // 弹幕设置
  int danmakuOpacity = 100; // 不透明度
  // 显示区域["1/4屏", "半屏", "3/4屏", "不重叠", "无限"]，选择下标，默认半屏（下标1）
  int danmakuDisplayArea = 1; // 显示区域
  // 区间[20, 100]， 默认20
  int danmakuFontSize = 80;
  // 弹幕播放速度["极慢", "较慢", "正常", "较快", "极快"], 选择许下标， 默认正常（下标2）
  int danmakuSpeed = 2;

  // 弹幕屏蔽类型
  bool danmakuShieldingRepeat =
      PlayerConfig.danmakuShieldingRepeat; // 屏蔽重复
  bool danmakuShieldingTop = PlayerConfig.danmakuShieldingTop; // 屏蔽顶部
  bool danmakuShieldingBottom =
      PlayerConfig.danmakuShieldingBottom; // 屏蔽底部
  bool danmakuShieldingRoll = PlayerConfig.danmakuShieldingRoll; // 屏蔽滚动
  bool danmakuShieldingColour =
      PlayerConfig.danmakuShieldingColour; // 屏蔽彩色

  // 弹幕调整时间(秒)
  double danmakuAdjustTime = 0.0;

  // 开启屏蔽词
  bool openDanmakuShieldingWord = PlayerConfig.openDanmakuShieldingWord;

  // 视频章节列表
  var videoChapterList = <FileModel>[];
  var maxVideoNameLen = 0;
  var playVideoChapter = "";

  // UI
  Widget? danmakuUI; // 弹幕UI
  bool danmakuUICreateSuccess = false; // 弹幕UI是否创建成功

  var platform = const MethodChannel('JIN_DANMAKU_NATIVE_VIEW');
}

/// 播放器方法
abstract class IPlayerMethod {
  /// 播放器初始化
  Future<void> onInitPlayer();

  /// 销毁播放器
  Future<void> onDisposePlayer();

  /// 更新状态信息
  void updateState();

  void changeVideoUrl({bool autoPlay = false});

  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> entryFullScreen();
  Future<void> exitFullScreen();
  Future<void> seekTo(Duration position);
  Future<void> setPlaybackSpeed(double speed);
}

class VideoPlayerInfo {
  const VideoPlayerInfo(
      {required this.isInitialized,
        required this.isPlaying,
        required this.duration,
        required this.positionDuration,
        required this.bufferedDurationRange,
        required this.isFinished});
  final bool isInitialized;
  final bool isPlaying;
  final Duration duration;
  final Duration positionDuration;
  final List<BufferedDurationRange> bufferedDurationRange;
  final bool isFinished;
}
