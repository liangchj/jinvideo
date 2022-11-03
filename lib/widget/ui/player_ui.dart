import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinvideo/model/file_model.dart';
import 'package:jinvideo/utils/format_util.dart';
import 'package:jinvideo/utils/my_icons_utils.dart';

import '../../player/player_getx_controller.dart';
import '../../player/player_params.dart';
import '../../player/player_progress_bar.dart';

class PlayerUI extends StatefulWidget {
  const PlayerUI({Key? key}) : super(key: key);

  @override
  State<PlayerUI> createState() => _PlayerUIState();
}

class _PlayerUIState extends State<PlayerUI> {
  final PlayerGetxController _playerGetxController =
      Get.find<PlayerGetxController>();
  late PlayerParams _playerParams;

  Timer? _hideTimer;
  @override
  void initState() {
    _playerParams = _playerGetxController.playerParams;
    super.initState();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// 开始计时UI显示时间
  void _startHideTimer() {
    _hideTimer = Timer(UIData.uiShowDuration, () {
      _playerGetxController.changeShowTopAndBottomUIState(false);
    });
  }

  /// 重新计算显示/隐藏UI计时器
  void _cancelAndRestartTimer() {
    print("重新计算显示/隐藏UI计时器");
    _hideTimer?.cancel();
    _startHideTimer();
    _playerGetxController.changeShowTopAndBottomUIState(true);
  }

  /// 点击背景
  void _toggleBackground() {
    print("点击背景");
    if (_playerGetxController.haveUIShow()) {
      _playerGetxController.hideAllUI();
    } else {
      _cancelAndRestartTimer();
    }
  }

  List<Widget> _fullScreenUIList() {
    return [
      // 播放速度
      Positioned(top: 0, right: 0, bottom: 0, child: _buildPlaySpeedBarUI()),
      // 弹幕设置
      Positioned(
          top: 0, right: 0, bottom: 0, child: _buildDanmakuSettingBarUI()),
      // 弹幕源设置
      Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: _buildDanmakuSourceSettingBarUI()),
      // 视频章节列表
      Positioned(
          top: 0, right: 0, bottom: 0, child: _buildVideoChapterListBarUI()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation)
    {
      if (orientation == Orientation.portrait) {
        return Container();
      }
      return Stack(
        children: [
          // 背景部分，用于触发事件（UI显示、滑动进度、音量增减、亮度增减）
          Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleBackground,
                child: Container(
                  color: Colors.redAccent.withOpacity(0),
                ),
              )),
          // 顶部UI
          _buildTopBarUI(),
          // 底部UI
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBarUI(),
          ),
          ..._fullScreenUIList()
        ],
      );
    }
    );
  }

  /// 创建顶部UI
  Widget _buildTopBarUI() {
    print("更新顶部build");
    return GetBuilder<PlayerGetxController>(
        id: "topBarUI",
        builder: (_) {
          print("更新top");
          return AbsorbPointer(
            absorbing: !_playerParams.showTopUI,
            child: AnimatedSlide(
                offset: _playerParams.showTopUI
                    ? const Offset(0, 0)
                    : const Offset(0, -1),
                duration: UIData.uiShowAnimationDuration,
                child: MouseRegion(
                  onHover: (_) {
                    print("点击了顶部UI");
                    if (_playerParams.showTopUI) {
                      _cancelAndRestartTimer();
                    }
                  },
                  /*onTap: () {
                    print("点击了顶部UI");
                    if (_playerParams.showTopUI) {
                      _cancelAndRestartTimer();
                    }
                  },*/
                  child: Container(
                    // 背景渐变效果
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: UIData.gradientBackground)),
                    child: Row(
                      children: [
                        const BackButton(
                          color: Colors.white,
                        ),
                        const Expanded(
                            child: Text(
                          "标题",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white),
                        )),
                        //右边部分
                        IconButton(
                            padding: const EdgeInsets.only(left: 20),
                            onPressed: () {
                              print("顶部右边按钮");
                            },
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                )),
          );
        });
  }

  /// 构建底部UI
  Widget _buildBottomBarUI() {
    return GetBuilder<PlayerGetxController>(
        id: "bottomBarUI",
        builder: (_) {
          print("更新bottom");
          return AbsorbPointer(
            absorbing: !_playerParams.showBottomUI,
            child: AnimatedSlide(
                offset: _playerParams.showTopUI
                    ? const Offset(0, 0)
                    : const Offset(0, 1),
                duration: UIData.uiShowAnimationDuration,
                child: Container(
                  padding: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                      // 渐变颜色（上下至上）
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: UIData.gradientBackground)),
                  child: MouseRegion(
                    onHover: (_) {
                      print("点击了底部UI");
                      if (_playerParams.showBottomUI) {
                        _cancelAndRestartTimer();
                      }
                    },
                    child: DefaultTextStyle(
                        style: const TextStyle(color: Colors.white),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: GetBuilder<PlayerGetxController>(
                                    id: "positionDuration",
                                    builder: (_) => Text(durationToMinuteAndSecond(
                                              _.playerParams.positionDuration))),
                                ),
                                _buildProgressBar(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: GetBuilder<PlayerGetxController>(
                                    id: "duration",
                                    builder: (_) => Text(
                                        durationToMinuteAndSecond(
                                            _playerParams.duration)),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildPlayPause(),
                                // 下一个视频
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.skip_next_rounded,
                                      color: Colors.white,
                                    )),
                                // 弹幕开关
                                GetBuilder<PlayerGetxController>(
                                    id: "showDanmakuBtn",
                                    builder: (_) => IconButton(
                                        onPressed: () {
                                          // _playerGetxController.showDanmaku(!_playerGetxController.showDanmaku.value);
                                          // _playerGetxController.update(["showDanmakuBtn"]);
                                        },
                                        icon: _playerParams.showDanmaku
                                            ? const Icon(
                                                MyIconsUtils.danmakuOpen,
                                                color: Colors.redAccent)
                                            : const Icon(
                                                MyIconsUtils.danmakuClose,
                                                color: Colors.white))),
                                // 弹幕源
                                TextButton(
                                  onPressed: () async {
                                    _hideTimer?.cancel();
                                    _playerGetxController.hideAllUI();
                                    _playerGetxController.changeShowDanmakuSourceSettingState(true);
                                  },
                                  child: const Text(
                                    "A",
                                  ),
                                ),
                                // 弹幕设置
                                IconButton(
                                    onPressed: () {
                                      _hideTimer?.cancel();
                                      _playerGetxController.hideAllUI();
                                      _playerGetxController.changeShowDanmakuSettingState(true);
                                    },
                                    icon: const Icon(
                                      MyIconsUtils.danmakuSetting,
                                      color: Colors.white,
                                    )),
                                Expanded(child: Container()),
                                // 选集
                                TextButton(
                                  onPressed: () {
                                    _hideTimer?.cancel();
                                    _playerGetxController.hideAllUI();
                                    _playerGetxController.changeShowVideoChapterListState(true);
                                  },
                                  child: const Text("选集"),
                                ),

                                // 倍数
                                TextButton(
                                  onPressed: () {
                                    _hideTimer?.cancel();
                                    _playerGetxController.hideAllUI();
                                    _playerGetxController.changeShowPlaySpeedSettingState(true);
                                  },
                                  child: const Text("倍数"),
                                ),

                                // 视频清晰度
                                TextButton(
                                  onPressed: () {
                                    _hideTimer?.cancel();
                                  },
                                  child: const Text("高清"),
                                ),
                              ],
                            )
                          ],
                        )),
                  ),
                )),
          );
        });
  }

  /// 播放、暂停按钮
  Widget _buildPlayPause({double? size}) {
    return IconButton(
      onPressed: () => _playerGetxController.playOrPause(),
      icon: GetBuilder<PlayerGetxController>(
        id: "playPauseBtn",
        builder: (_) {
          print("更新播放按钮");
          var isFinished = _playerParams.isFinished;
          var isPlaying = _playerParams.isPlaying;
          return Icon(
            isFinished
                ? Icons.replay_rounded
                : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
            size: size,
            color: Colors.white,
          );
        },
      ),
    );
  }

  /// 进度条
  Widget _buildProgressBar() {
    return Expanded(
      child: GetBuilder<PlayerGetxController>(
          id: "playProgress",
          builder: (_) {
            if (!_playerParams.showBottomUI) {
              return Container();
            }
            print("播放进度：${_playerParams.positionDuration}");
            return AbsorbPointer(
              absorbing: !_playerParams.isInitialized,
              child: PlayerProgressBar(
                progress: _playerParams.positionDuration,
                totalDuration: _playerParams.duration,
                bufferedDurationRange: _playerParams.bufferedDurationRange,
                barHeight: 4.0,
                thumbShape: ProgressBarThumbShape(
                    thumbColor: Colors.redAccent,
                    thumbRadius: 8.0,
                    thumbInnerColor: Colors.white,
                    thumbInnerRadius: 3.0),
                thumbOverlayColor: Colors.redAccent.withOpacity(0.24),
                thumbOverlayShape: ProgressBarThumbOverlayShape(
                    thumbOverlayColor: Colors.redAccent.withOpacity(0.5),
                    thumbOverlayRadius: 16.0),
                onChangeStart: (details) {
                  print("进度条改变开始");
                  _hideTimer?.cancel();
                  _playerParams.isDragging = true;
                },
                onChangeEnd: (details) {
                  print("进度条改变结束");
                  if (_playerParams.isPlaying) {
                    _playerGetxController.pause();
                    _playerParams.beforeSeekIsPlaying = true;
                  } else {
                    _playerParams.beforeSeekIsPlaying = false;
                  }
                  _playerParams.isDragging = false;
                },
                onChanged: (details) {
                  print("进度条改变事件");
                },
                onSeek: (details) async {
                  await _playerGetxController
                      .seekTo(details.currentDuration)
                      .then((value) async {
                    if (_playerParams.beforeSeekIsPlaying) {
                      await _playerGetxController.play();
                    }
                  });
                  _startHideTimer();
                },
              ),
            );
          }),
    );
  }

  /// 播放速度
  Widget _buildPlaySpeedBarUI() {
    double width = MediaQuery.of(context).size.width;
    double boxWidth = width * 0.45;
    return GetBuilder<PlayerGetxController>(
        id: "playSpeedSetting",
        builder: (_) {
          var showPlaySpeedSetting = _playerParams.showPlaySpeedSetting;
          return AnimatedSlide(
            offset:
                showPlaySpeedSetting ? const Offset(0, 0) : const Offset(1, 0),
            duration: UIData.uiShowAnimationDuration,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: boxWidth, minWidth: 100),
              child: Container(
                // width: boxWidth,
                height: double.infinity,
                color: Colors.black38.withOpacity(0.6),
                padding: const EdgeInsets.all(10.0),
                child: GetBuilder<PlayerGetxController>(
                    id: "playSpeed",
                    builder: (_) => SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                                  .map((e) {
                                Color fontSize = e == _playerParams.playSpeed
                                    ? Colors.redAccent
                                    : Colors.white;
                                return TextButton(
                                    onPressed: () {
                                      _playerParams.playSpeed = e;
                                      _playerGetxController
                                          .update(["playSpeed"]);
                                    },
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                horizontal: 60))),
                                    child: Text(
                                      "${e}x",
                                      style: TextStyle(color: fontSize),
                                      textAlign: TextAlign.center,
                                    ));
                              }).toList()),
                        )),
              ),
            ),
          );
        });
  }

  /// 弹幕设置
  Widget _buildDanmakuSettingBarUI() {
    double width = MediaQuery.of(context).size.width;
    double boxWidth = width * 0.45;
    return GetBuilder<PlayerGetxController>(
        id: "danmakuSetting",
        builder: (_) {
          var showDanmakuSetting = _playerParams.showDanmakuSetting;
          return AnimatedSlide(
            offset:
                showDanmakuSetting ? const Offset(0, 0) : const Offset(1, 0),
            duration: UIData.uiShowAnimationDuration,
            child: Container(
              width: boxWidth,
              height: double.infinity,
              color: Colors.black38.withOpacity(0.6),
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 弹幕设置
                    Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BuildTextWidget(
                              text: "弹幕设置",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 18),
                              edgeInsets: EdgeInsets.only(
                                  left: 5, top: 10, right: 5, bottom: 10)),
                        ),
                        Column(
                          children: [
                            // 弹幕不透明度设置
                            _danmakuOpacitySetting(),
                            // 弹幕显示区域设置
                            _danmakuDisplayAreaSetting(),
                            // 弹幕字号设置
                            _danmakuFontSizeSetting(),
                            // 弹幕速度设置
                            _danmakuSpeedSetting()
                          ],
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                    // 屏蔽类型
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BuildTextWidget(
                              text: "屏蔽类型",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 18),
                              edgeInsets: EdgeInsets.only(
                                  left: 5, top: 10, right: 5, bottom: 10)),
                        ),
                        FractionallySizedBox(
                          widthFactor: 1.0,
                          child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 16.0, // 主轴(水平)方向间距
                              runSpacing: 16.0, // 纵轴（垂直）方向间距
                              verticalDirection: VerticalDirection.down,
                              alignment: WrapAlignment.spaceBetween, //
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GetBuilder<PlayerGetxController>(
                                    id: "duplicateMergingEnabled",
                                    builder: (_) => GestureDetector(
                                          onTapDown: (details) {
                                            _playerParams
                                                    .duplicateMergingEnabled =
                                                !_playerParams
                                                    .duplicateMergingEnabled;
                                            _playerGetxController.setDuplicateMergingEnabled();
                                            _playerGetxController.update(["duplicateMergingEnabled"]);
                                          },
                                          child: Column(
                                            children: [
                                              _playerParams
                                                      .duplicateMergingEnabled
                                                  ? const Icon(
                                                      MyIconsUtils
                                                          .repeatDanmakuOpen,
                                                      color: Colors.white)
                                                  : const Icon(
                                                      MyIconsUtils
                                                          .repeatDanmakuClose,
                                                      color: Colors.redAccent),
                                              const BuildTextWidget(
                                                text: "重复",
                                              ),
                                            ],
                                          ),
                                        )),
                                GetBuilder<PlayerGetxController>(
                                    id: "fixedTopDanmakuVisibility",
                                    builder: (_) => GestureDetector(
                                          onTapDown: (details) {
                                            _playerParams.fixedTopDanmakuVisibility =
                                                !_playerParams
                                                    .fixedTopDanmakuVisibility;
                                            _playerGetxController.setFixedTopDanmakuVisibility();
                                            _playerGetxController.update(["fixedTopDanmakuVisibility"]);
                                          },
                                          child: Column(
                                            children: [
                                              _playerParams.fixedTopDanmakuVisibility
                                                  ? const Icon(
                                                      MyIconsUtils
                                                          .topDanmakuOpen,
                                                      color: Colors.white)
                                                  : const Icon(
                                                      MyIconsUtils
                                                          .topDanmakuClose,
                                                      color: Colors.redAccent),
                                              const BuildTextWidget(
                                                text: "顶部",
                                              ),
                                            ],
                                          ),
                                        )),
                                GetBuilder<PlayerGetxController>(
                                    id: "rollDanmakuVisibility",
                                    builder: (_) => GestureDetector(
                                          onTapDown: (details) {
                                            _playerParams.rollDanmakuVisibility =
                                                !_playerParams
                                                    .rollDanmakuVisibility;
                                            _playerGetxController.setRollDanmakuVisibility();
                                            _playerGetxController.update(["rollDanmakuVisibility"]);
                                          },
                                          child: Column(
                                            children: [
                                              _playerParams.rollDanmakuVisibility
                                                  ? const Icon(
                                                      MyIconsUtils
                                                          .rollDanmakuOpen,
                                                      color: Colors.white)
                                                  : const Icon(
                                                      MyIconsUtils
                                                          .rollDanmakuClose,
                                                      color: Colors.redAccent),
                                              const BuildTextWidget(
                                                text: "滚动",
                                              ),
                                            ],
                                          ),
                                        )),
                                GetBuilder<PlayerGetxController>(
                                    id: "fixedBottomDanmakuVisibility",
                                    builder: (_) => GestureDetector(
                                          onTapDown: (details) {
                                            _playerParams
                                                    .fixedBottomDanmakuVisibility =
                                                !_playerParams
                                                    .fixedBottomDanmakuVisibility;
                                            _playerGetxController.setFixedBottomDanmakuVisibility();
                                            _playerGetxController.update(["fixedBottomDanmakuVisibility"]);
                                          },
                                          child: Column(
                                            children: [
                                              _playerParams
                                                      .fixedBottomDanmakuVisibility
                                                  ? const Icon(
                                                      MyIconsUtils
                                                          .bottomDanmakuOpen,
                                                      color: Colors.white)
                                                  : const Icon(
                                                      MyIconsUtils
                                                          .bottomDanmakuClose,
                                                      color: Colors.redAccent),
                                              const BuildTextWidget(
                                                text: "底部",
                                              ),
                                            ],
                                          ),
                                        )),
                                GetBuilder<PlayerGetxController>(
                                    id: "colorsDanmakuVisibility",
                                    builder: (_) => GestureDetector(
                                          onTapDown: (details) {
                                            _playerParams
                                                    .colorsDanmakuVisibility =
                                                !_playerParams
                                                    .colorsDanmakuVisibility;
                                            _playerGetxController.setColorsDanmakuVisibility();
                                            _playerGetxController.update(["colorsDanmakuVisibility"]);
                                          },
                                          child: Column(
                                            children: [
                                              _playerParams
                                                      .colorsDanmakuVisibility
                                                  ? const Icon(
                                                      MyIconsUtils
                                                          .colorDanmakuOpen,
                                                      color: Colors.white)
                                                  : const Icon(
                                                      MyIconsUtils
                                                          .colorDanmakuClose,
                                                      color: Colors.redAccent),
                                              const BuildTextWidget(
                                                text: "彩色",
                                              ),
                                            ],
                                          ),
                                        )),
                              ]),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 5)),

                    /// 时间调整
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BuildTextWidget(
                              text: "时间调整(秒)",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 18),
                              edgeInsets: EdgeInsets.only(
                                  left: 5, top: 10, right: 5, bottom: 10)),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _playerParams.danmakuAdjustTime =
                                          _playerParams.danmakuAdjustTime - 0.5;
                                      _playerGetxController
                                          .update(["danmakuAdjustTime"]);
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_rounded,
                                      color: Colors.white,
                                    )),
                                GetBuilder<PlayerGetxController>(
                                    id: "danmakuAdjustTime",
                                    builder: (_) => BuildTextWidget(
                                        text:
                                            "${_playerParams.danmakuAdjustTime}")),
                                IconButton(
                                    onPressed: () {
                                      _playerParams.danmakuAdjustTime =
                                          _playerParams.danmakuAdjustTime + 0.5;
                                      _playerGetxController
                                          .update(["danmakuAdjustTime"]);
                                    },
                                    icon: const Icon(Icons.add_circle_rounded,
                                        color: Colors.white)),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _playerGetxController.danmakuSeekTo(),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.5))),
                              child: const Text("同步弹幕时间"),
                            )),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 5)),

                    /// 弹幕屏蔽词
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: BuildTextWidget(
                                  text: "弹幕屏蔽词",
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 18),
                                  edgeInsets: EdgeInsets.only(
                                      left: 5, top: 10, right: 5, bottom: 10)),
                            ),
                            GetBuilder<PlayerGetxController>(
                                id: "openDanmakuShieldingWord",
                                builder: (_) => Switch(
                                      value: _playerParams
                                          .openDanmakuShieldingWord, //当前状态
                                      onChanged: (value) {
                                        _playerParams.openDanmakuShieldingWord =
                                            !_playerParams
                                                .openDanmakuShieldingWord;
                                        _playerGetxController.update(
                                            ["openDanmakuShieldingWord"]);
                                      },
                                    ))
                          ],
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.5))),
                              child: const Text("弹幕屏蔽管理"),
                            )),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 5)),

                    /// 弹幕列表
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BuildTextWidget(
                              text: "弹幕列表",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 20),
                              edgeInsets: EdgeInsets.only(
                                  left: 5, top: 10, right: 5, bottom: 10)),
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.5))),
                              child: const Text("查看弹幕列表"),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// 弹幕不透明度设置
  Widget _danmakuOpacitySetting() {
    return GetBuilder<PlayerGetxController>(
        id: "opacitySetting",
        builder: (_) {
          return Row(
            children: [
              /// 左边文字说明
              const Padding(
                padding:
                    EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
                child: Text(
                  "不透明度",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              /// 中间进度指示器
              Expanded(
                child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        trackShape: const MySliderTrackShape(),
                        activeTrackColor: Colors.redAccent,
                        inactiveTrackColor: Colors.white60,
                        inactiveTickMarkColor: Colors.white,
                        tickMarkShape:
                            const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          //可继承SliderComponentShape自定义形状
                          disabledThumbRadius: 4, //禁用时滑块大小
                          enabledThumbRadius: 4, //滑块大小
                        ),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 8)),
                    child: Slider(
                      value: _playerParams.danmakuOpacity.toDouble(),
                      min: 0,
                      max: 100,
                      onChanged: (value) {
                        _playerParams.danmakuOpacity = value.toInt();
                        _playerGetxController.update(["opacitySetting"]);
                      },
                    )),
              ),

              /// 右边进度提示
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 16 * 2.5, // 默认显示两个字+%
                ),
                child: Text(
                  "${_playerParams.danmakuOpacity}%",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  /// 弹幕显示区域设置
  Widget _danmakuDisplayAreaSetting() {
    var areaList = ["1/4屏", "半屏", "3/4屏", "不重叠", "无限"];
    return GetBuilder<PlayerGetxController>(
        id: "displayAreaSetting",
        builder: (_) {
          return Row(
            children: [
              /// 左边文字说明
              const Padding(
                padding:
                    EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
                child: Text(
                  "显示区域",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              /// 中间进度指示器
              Expanded(
                child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        trackShape: const MySliderTrackShape(),
                        activeTrackColor: Colors.redAccent,
                        inactiveTrackColor: Colors.white60,
                        inactiveTickMarkColor: Colors.white,
                        tickMarkShape:
                            const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          //可继承SliderComponentShape自定义形状
                          disabledThumbRadius: 4, //禁用时滑块大小
                          enabledThumbRadius: 4, //滑块大小
                        ),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 8)),
                    child: Slider(
                      value: _playerParams.danmakuDisplayArea.toDouble(),
                      min: 0,
                      max: 4,
                      divisions: 4,
                      onChanged: (value) {
                        _playerParams.danmakuDisplayArea = value.toInt();
                        _playerGetxController.update(["displayAreaSetting"]);
                      },
                    )),
              ),

              /// 右边进度提示
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 16 * 2.5, // 默认显示两个字+%
                ),
                child: Text(
                  areaList[_playerParams.danmakuDisplayArea],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  /// 弹幕字号设置
  Widget _danmakuFontSizeSetting() {
    return GetBuilder<PlayerGetxController>(
        id: "danmakuFontSizeSetting",
        builder: (_) {
          return Row(
            children: [
              /// 左边文字说明
              const Padding(
                padding:
                    EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
                child: Text(
                  "弹幕字号",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              /// 中间进度指示器
              Expanded(
                child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        trackShape: const MySliderTrackShape(),
                        activeTrackColor: Colors.redAccent,
                        inactiveTrackColor: Colors.white60,
                        inactiveTickMarkColor: Colors.white,
                        tickMarkShape:
                            const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          //可继承SliderComponentShape自定义形状
                          disabledThumbRadius: 4, //禁用时滑块大小
                          enabledThumbRadius: 4, //滑块大小
                        ),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 8)),
                    child: Slider(
                      value: _playerParams.danmakuFontSize.toDouble(),
                      min: 20,
                      max: 200,
                      onChanged: (value) {
                        _playerParams.danmakuFontSize = value.toInt();
                        _playerGetxController.update(["danmakuFontSizeSetting"]);
                        _playerGetxController.setDanmakuScaleTextSize();
                      },
                    )),
              ),

              /// 右边进度提示
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 16 * 2.5, // 默认显示两个字+%
                ),
                child: Text(
                  "${_playerParams.danmakuFontSize}%",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  /// 弹幕速度设置
  Widget _danmakuSpeedSetting() {
    var speedList = ["极慢", "较慢", "正常", "较快", "极快"];
    return GetBuilder<PlayerGetxController>(
        id: "danmakuSpeedSetting",
        builder: (_) {
          return Row(
            children: [
              /// 左边文字说明
              const Padding(
                padding:
                    EdgeInsets.only(left: 5, top: 10, right: 5, bottom: 10),
                child: Text(
                  "弹幕速度",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              /// 中间进度指示器
              Expanded(
                child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        trackShape: const MySliderTrackShape(),
                        activeTrackColor: Colors.redAccent,
                        inactiveTrackColor: Colors.white60,
                        inactiveTickMarkColor: Colors.white,
                        tickMarkShape:
                            const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          //可继承SliderComponentShape自定义形状
                          disabledThumbRadius: 4, //禁用时滑块大小
                          enabledThumbRadius: 4, //滑块大小
                        ),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 8)),
                    child: Slider(
                      value: _playerParams.danmakuSpeed.toDouble(),
                      min: 0,
                      max: 4,
                      divisions: 4,
                      onChanged: (value) {
                        _playerParams.danmakuSpeed = value.toInt();
                        _playerGetxController.update(["danmakuSpeedSetting"]);
                        _playerGetxController.setDanmakuSpeed();
                      },
                    )),
              ),

              /// 右边进度提示
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 16 * 2.5, // 默认显示两个字+%
                ),
                child: Text(
                  speedList[_playerParams.danmakuSpeed],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  /// 弹幕源
  Widget _buildDanmakuSourceSettingBarUI() {
    double width = MediaQuery.of(context).size.width;
    double boxWidth = width * 0.45;
    return GetBuilder<PlayerGetxController>(
        id: "danmakuSourceSetting",
        builder: (_) {
          var showDanmakuSourceSetting = _playerParams.showDanmakuSourceSetting;
          return AnimatedSlide(
            offset: showDanmakuSourceSetting
                ? const Offset(0, 0)
                : const Offset(1, 0),
            duration: UIData.uiShowAnimationDuration,
            child: Container(
              width: boxWidth > 300 ? boxWidth : 300,
              height: double.infinity,
              color: Colors.black38.withOpacity(0.6),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BuildTextWidget(
                        text: "弹幕源",
                        style: TextStyle(color: Colors.white54, fontSize: 20),
                        edgeInsets: EdgeInsets.only(
                            left: 5, top: 10, right: 5, bottom: 10)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.5))),
                      child: const Text("添加本地弹幕"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.5))),
                      child: const Text("添加网络弹幕"),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BuildTextWidget(
                        text: "当前绑定弹幕",
                        style: TextStyle(color: Colors.white54, fontSize: 20),
                        edgeInsets: EdgeInsets.only(
                            left: 5, top: 10, right: 5, bottom: 10)),
                  ),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: BuildTextWidget(
                        text:
                            ",fsdfgsadgfsgabcsarvyawsetryateratrtaytsytr6356wvc36c",
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  /// 视频章节列表
  Widget _buildVideoChapterListBarUI() {
    double width = MediaQuery.of(context).size.width;
    double boxWidth = width * 0.45;
    return GetBuilder<PlayerGetxController>(
        id: "videoChapterList",
        builder: (_) {
          var showVideoChapterList = _playerParams.showVideoChapterList;
          return AnimatedSlide(
              offset: showVideoChapterList
                  ? const Offset(0, 0)
                  : const Offset(1, 0),
              duration: UIData.uiShowAnimationDuration,
              child: Container(
                width: boxWidth,
                height: double.infinity,
                color: Colors.black38.withOpacity(0.6),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BuildTextWidget(
                          text: "选集（${_playerParams.videoChapterList.length}）",
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 20),
                          edgeInsets: const EdgeInsets.only(
                              left: 5, top: 10, right: 5, bottom: 10)),
                    ),
                    Expanded(
                        child: _playerParams.maxVideoNameLen > 4
                            ? _buildNormalLayout()
                            : _buildGridViewLayout())
                  ],
                ),
              ));
        });
  }

  /// 普通列表排版
  Widget _buildNormalLayout() {
    List<FileModel> videoChapterList = _playerParams.videoChapterList;
    double fontSize = 18;
    Color defaultFontColor = Colors.white;
    Color playFontColor = Colors.redAccent;
    return ListView.builder(
      prototypeItem: const ListTile(title: Text("章节")),
      itemCount: videoChapterList.length,
      itemBuilder: (context, index) {
        FileModel videoModel = videoChapterList[index];
        return GetBuilder<PlayerGetxController>(
            id: "videoChapterNormalLayout",
            builder: (_) {
              bool isPlaying =
                  videoModel.path == _playerParams.playVideoChapter;
              double iconOpacity = isPlaying ? 1.0 : 0;
              Color fontColor = isPlaying ? playFontColor : defaultFontColor;
              return Container(
                color: Colors.white.withOpacity(0.3),
                margin:
                    const EdgeInsets.only(left: 5, top: 6, right: 5, bottom: 6),
                child: InkWell(
                  onTap: () =>
                      _playerParams..playVideoChapter = videoModel.path,
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: fontSize,
                        color: Colors.redAccent.withOpacity(iconOpacity),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(
                            videoModel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: fontSize,
                                color: fontColor,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  /// 网格排版
  Widget _buildGridViewLayout() {
    List<FileModel> videoChapterList = _playerParams.videoChapterList;
    double fontSize = 18;
    // 文字颜色
    Color defaultFontColor = Colors.white;
    Color playFontColor = Colors.redAccent;
    // 边框样式
    // 边框颜色
    Color borderColor = Colors.white38;
    Color playBorderColor = Colors.redAccent;
    // 边框宽度
    double borderWidth = 1.0;
    double playBorderWidth = borderWidth * 2;
    // 边框圆角
    double borderRadius = 6.0;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, //每行四列
          childAspectRatio: 1.0, //显示区域宽高相等
          mainAxisSpacing: 10,
          crossAxisSpacing: 10),
      itemCount: videoChapterList.length,
      itemBuilder: (context, index) {
        FileModel videoModel = videoChapterList[index];
        late ShapeBorder shape;
        late Color fontColor;
        return GetBuilder<PlayerGetxController>(
            id: "videoChapterGridViewLayout",
            builder: (_) {
              if (videoModel.path == _playerParams.playVideoChapter) {
                shape = RoundedRectangleBorder(
                    //边框颜色
                    side: BorderSide(
                      color: playBorderColor,
                      width: playBorderWidth,
                    ),
                    //边框圆角
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ));
                fontColor = playFontColor;
              } else {
                shape = RoundedRectangleBorder(
                    //边框颜色
                    side: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                    //边框圆角
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ));
                fontColor = defaultFontColor;
              }

              return MaterialButton(
                //边框样式
                shape: shape,
                onPressed: () {
                  _playerParams.playVideoChapter = videoModel.path;
                },
                child: Text(
                  videoModel.name,
                  style: TextStyle(fontSize: fontSize, color: fontColor),
                ),
              );
            });
      },
    );
  }
}

/// 清除已划过进度高度变高问题
class MySliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const MySliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);

    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr) ? trackRect.top : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl) ? trackRect.top : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}

/// 文本框Widget
class BuildTextWidget extends StatelessWidget {
  const BuildTextWidget(
      {Key? key, required this.text, this.style, this.edgeInsets})
      : super(key: key);
  final String text;
  final TextStyle? style;
  final EdgeInsets? edgeInsets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsets ?? const EdgeInsets.only(left: 5, right: 5),
      child: Text(text, style: style ?? const TextStyle(color: Colors.white)),
    );
  }
}

/// UI需要的数据
class UIData {
  static List<Color> gradientBackground = [
    Colors.black54,
    Colors.black45,
    Colors.black38,
    Colors.black26,
    Colors.black12,
    Colors.transparent
  ];
  static Duration uiShowAnimationDuration = const Duration(milliseconds: 300);
  static Duration uiHideAnimationDuration = const Duration(milliseconds: 300);
  static Duration iconChangeDuration = const Duration(milliseconds: 75);
  static Duration uiShowDuration = const Duration(seconds: 5);
}
