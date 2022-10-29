package com.lchj.jinvideo.danmaku

import android.content.Context
import android.util.Log
import android.view.View
import com.lchj.jinvideo.utils.LogTagUtils
import com.lchj.jinvideo.utils.MethodChannelUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class JinDanmakuView(
    private var context: Context?,
    messenger: BinaryMessenger,
    viewId: Int,
    args: Map<String, Any>?
) :
    PlatformView, MethodChannel.MethodCallHandler {
    private var methodChannel: MethodChannel
    private var args: Map<String, Any> = args ?: hashMapOf()

    init {
        Log.d(LogTagUtils.DANMAKU_ANDROID_VIEW_LOG_TAG, "JinDanmakuView viewId: $viewId")
        methodChannel = MethodChannel(messenger, MethodChannelUtils.METHOD_CHANNEL_DANMAKU_VIEW)
        methodChannel.setMethodCallHandler(this)
    }
    override fun getView(): View {
        return DanmakuViewUtils.getView(context, args)
    }

    override fun dispose() {
        DanmakuViewUtils.dispose()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) =
        when (call.method) {
            "sendDanmaku" -> { // 启动弹幕
                val danmakuText: String? = call.argument<Long>("danmakuText") as String?
                if (danmakuText != null && danmakuText.isNotEmpty()) {
                    DanmakuViewUtils.sendDanmaku(false, danmakuText)
                }
                result.success(true)
            }
            "startDanmaku" -> { // 启动弹幕
                val msStr = call.argument<Long>("time") as String?
                DanmakuViewUtils.startDanmaku(if (msStr != null && msStr.isNotEmpty()) msStr.toLong() else null)
                result.success(true)
            }
            "pauseDanmaKu" -> { // 暂停弹幕
                DanmakuViewUtils.pauseDanmaKu()
                result.success(true)
            }
            "resumeDanmaku" -> { // 继续弹幕
                DanmakuViewUtils.resumeDanmaku()
                result.success(true)
            }
            "showDanmaKu" -> { // 显示弹幕
                DanmakuViewUtils.setDanmaKuVisibility(true)
                result.success(true)
            }
            "hideDanmaKu" -> { // 隐藏弹幕
                DanmakuViewUtils.setDanmaKuVisibility(false)
                result.success(true)
            }
            "danmaKuSeekTo" -> { // 跳转弹幕
                val ms: String = call.argument<String>("time") as String
                DanmakuViewUtils.danmaKuSeekTo(ms.toLong())
                result.success(true)
            }
            "setDanmakuSpeed" -> { // 设置滚动速度
                DanmakuViewUtils.setDanmakuSpeed((call.argument<Long>("speed") as Double?)?.toFloat())
                result.success(true)
            }
            "setDanmakuScaleTextSize" -> { // 设置字体大小
                val danmakuFontSize: Int? = call.argument<Int>("danmakuFontSize")
                DanmakuViewUtils.setDanmakuScaleTextSize(danmakuFontSize)
                result.success(true)
            }
            "setDuplicateMergingEnabled" -> { // 设置是否启用合并重复弹幕
                var flag: Boolean = call.argument<Boolean>("flag") as Boolean
                DanmakuViewUtils.setDuplicateMergingEnabled(flag)
                result.success(true)
            }
            "setFixedTopDanmakuVisibility" -> { // 设置是否显示顶部固定弹幕
                var visible: Boolean = call.argument<Boolean>("visible")  as Boolean
                DanmakuViewUtils.setFixedTopDanmakuVisibility(visible)
                result.success(true)
            }
            "setFixedBottomDanmakuVisibility" -> { // 设置是否显示底部固定弹幕
                var visible: Boolean = call.argument<Boolean>("visible")  as Boolean
                DanmakuViewUtils.setFixedBottomDanmakuVisibility(visible)
                result.success(true)
            }
            "setRollDanmakuVisibility" -> { // 设置是否显示滚动弹幕
                var visible: Boolean = call.argument<Boolean>("visible")  as Boolean
                DanmakuViewUtils.setRollDanmakuVisibility(visible)
                result.success(true)
            }
            "setSpecialDanmakuVisibility" -> { // 设置是否显示特殊弹幕
                var visible: Boolean = call.argument<Boolean>("visible")  as Boolean
                DanmakuViewUtils.setSpecialDanmakuVisibility(visible)
                result.success(true)
            }
            "setColorsDanmakuVisibility" -> { // 是否显示彩色弹幕
                var visible: Boolean = call.argument<Boolean>("visible")  as Boolean
                DanmakuViewUtils.setColorsDanmakuVisibility(visible)
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }

}
// 弹幕引擎
enum class DanmakuType {
    BILI, // 哔哩哔哩弹幕
    AK // 快手弹幕
}
// 弹幕view默认有获取和销毁方法
interface IJinDanmakuView {
    fun getView(): View
    fun dispose()

    /**
     * 开启弹幕
     */
    fun startDanmaku(position: Long?)

    /**
     * 暂停弹幕
     */
    fun pauseDanmaKu()

    /**
     * 继续弹幕
     */
    fun resumeDanmaku()

    /**
     * 获取当前弹幕时间
     */
    fun danmakuCurrentTime(): Long

    /**
     * 显示或隐藏
     */
    fun setDanmaKuVisibility(visible: Boolean)

    /**
     * 弹幕跳转
     */
    fun danmaKuSeekTo(position: Long)

    /**
     * 设置弹幕滚动速度
     */
    fun setDanmakuSpeed(speed: Float)

    /**
     * 设置弹幕文字大小
     */
    fun setDanmakuScaleTextSize(fontSize: Int)

    /**
     * 设置最大显示行数
     */
    fun setDanmakuMaximumLines(areaIndex: Int)

    /**
     * 发送弹幕
     */
    fun sendDanmaku(isLive: Boolean, text: String)

    /**
     * 设置是否启用合并重复弹幕
     */
    fun setDuplicateMergingEnabled(flag: Boolean)

    /**
     * 设置是否显示顶部固定弹幕
     */
    fun setFixedTopDanmakuVisibility(visible: Boolean)

    /**
     * 设置是否显示底部固定弹幕
     */
    fun setFixedBottomDanmakuVisibility(visible: Boolean)

    /**
     * 设置是否显示左右滚动弹幕
     */
    fun setRollDanmakuVisibility(visible: Boolean)

    /**
     * 设置是否显示特殊弹幕
     */
    fun setSpecialDanmakuVisibility(visible: Boolean)

    /**
     * 是否显示彩色弹幕
     */
    fun setColorsDanmakuVisibility(visible: Boolean)
}
