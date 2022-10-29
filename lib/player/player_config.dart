
class PlayerConfig {
  static double aspectRatio = 16.0 / 9.0; // 播放器比例
  static bool autoPlay = false; // 自动播放
  static bool looping = false; // 循环播放

  // 全屏播放（直接进入全屏播放，且只能进行全屏播放）
  static bool fullScreenPlay = false;

  // 播放速度
  static double videoPlaySpeed = 1.0;
  // 视频清晰度
  static String videoQuality = "1080p";

  static bool showDanmaku = true; // 显示弹幕UI

  // 弹幕设置
  static int danmakuOpacity = 100; // 不透明度
  // 显示区域["1/4屏", "半屏", "3/4屏", "不重叠", "无限"]，选择下标，默认半屏（下标1）
  static int danmakuDisplayArea = 1; // 显示区域
  // 区间[20, 100]， 默认20
  static int danmakuFontSize = 80;
  // 弹幕播放速度["极慢", "较慢", "正常", "较快", "极快"], 选择许下标， 默认正常（下标2）
  static int danmakuSpeed = 2;
  static List<double> danmakuSpeedList = [0.5, 0.75, 1.0, 1.25, 1.5];
  // static List<double> danmakuSpeedList = [1.5, 1.25, 1.0, 0.75, 0.5]; // 不知为何速度系数是反着来的的

  // 弹幕屏蔽类型
  static bool danmakuShieldingRepeat = false; // 屏蔽重复
  static bool danmakuShieldingTop = false; // 屏蔽顶部
  static bool danmakuShieldingBottom = false; // 屏蔽底部
  static bool danmakuShieldingRoll = false; // 屏蔽滚动
  static bool danmakuShieldingColour = false; // 屏蔽彩色

  // 开启屏蔽词
  static bool openDanmakuShieldingWord = false;
}
