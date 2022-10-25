package com.lchj.jinvideo.danmaku

import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import android.view.View
import com.lchj.jinvideo.danmaku.ak.AKDanmakuView
import com.lchj.jinvideo.danmaku.bili.BiliDanmakuView
import com.lchj.jinvideo.utils.LogTagUtils
import org.apache.commons.collections4.MapUtils

@SuppressLint("StaticFieldLeak")
object DanmakuViewUtils {
    private var biliDanmakuView : BiliDanmakuView? = null
    private var akDanmakuView : AKDanmakuView? = null
    // AndroidView
    private var danmakuView : View? = null
    private var danmakuUrl : String = ""
    // 默认使用哔哩哔哩弹幕
    private var danmakuType: DanmakuType = DanmakuType.BILI
    /**
     * 获取弹幕VIEW
     */
    fun getView(context: Context?, args: Map<String, Any>): View {
        Log.d(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "getView")
        // 是否重新创建
        val rebuild: Boolean = MapUtils.getBoolean(args, "rebuild", false)
        danmakuUrl = MapUtils.getString(args, "danmakuUrl", "")
        val type = MapUtils.getString(args, "danmakuType", "")
        danmakuType = if (type == "AK") DanmakuType.AK else DanmakuType.BILI

        // 弹幕路径为空时返回空的view
        if (danmakuUrl.isEmpty()) {
            dispose()
            return View(context)
        }
        Log.d(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "danmakuUrl: $danmakuUrl")
        Log.d(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "danmakuType: $danmakuType")
        when (danmakuType) {
            DanmakuType.BILI -> {
                // 直接重绘/还未创建view/弹幕地址不一致
                if (rebuild || biliDanmakuView == null || this.danmakuUrl != danmakuUrl) {
                    biliDanmakuViewDispose() // 先将之前创建的清除
                    danmakuView = null
                    biliDanmakuView = BiliDanmakuView(context, danmakuUrl, args)
                }
                akDanmakuViewDispose() // 创建哔哩哔哩view，因此要销毁AK弹幕
                danmakuView = biliDanmakuView?.getView()
            }
            DanmakuType.AK -> {
                // 直接重绘/还未创建view/弹幕地址不一致
                if (rebuild || akDanmakuView == null || this.danmakuUrl != danmakuUrl) {
                    akDanmakuViewDispose() // 先将之前创建的清除
                    danmakuView = null
                    akDanmakuView = AKDanmakuView(context, danmakuUrl, args)
                }
                biliDanmakuViewDispose() // 创建AK view，因此要销毁哔哩哔哩弹幕
                danmakuView = akDanmakuView?.getView()
            }
            else -> {
                dispose()
            }
        }
        return danmakuView ?: View(context)
    }

    /**
     * 销毁弹幕VIEW
     */
    fun dispose() {
        android.util.Log.d(com.lchj.jinvideo.utils.LogTagUtils.DANMAKU_UTILS_LOG_TAG, "销毁view")
        biliDanmakuViewDispose()
        akDanmakuViewDispose()
        biliDanmakuView = null
        akDanmakuView = null
        danmakuView  = null
        danmakuUrl  = ""
        danmakuType = DanmakuType.BILI
    }

    /**
     * 销毁哔哩哔哩弹幕VIEW
     */
    private fun biliDanmakuViewDispose() {
        if (biliDanmakuView != null) {
            biliDanmakuView?.dispose()
        }
    }

    /**
     * 销毁AK弹幕VIEW
     */
    private fun akDanmakuViewDispose() {
        if (akDanmakuView != null) {
            akDanmakuView?.dispose()
        }
    }

    /**
     * 开启弹幕
     */
    fun startDanmaku(position: Long?) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.startDanmaku(position)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.startDanmaku(position)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "startDanmaku 失败：$e")
        }
    }
    /**
     * 暂停弹幕
     */
    fun pauseDanmaKu() {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.pauseDanmaKu()
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.pauseDanmaKu()
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "pauseDanmaKu 失败：$e")
        }
    }

    /**
     * 继续弹幕
     */
    fun resumeDanmaku() {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.resumeDanmaku()
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.resumeDanmaku()
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "resumeDanmaku 失败：$e")
        }
    }

    /**
     * 发送弹幕
     */
    fun sendDanmaku(isLive: Boolean, text: String) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.sendDanmaku(isLive, text)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.sendDanmaku(isLive, text)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "sendDanmaku 失败：$e")
        }
    }

    /**
     * 获取当前弹幕时间
     */
    fun danmakuCurrentTime(): Long? {
        var currentTime: Long? = null
        try {
            if (danmakuType == DanmakuType.BILI) {
                currentTime = biliDanmakuView?.danmakuCurrentTime()
            }
            else if (danmakuType == DanmakuType.AK) {
                currentTime = akDanmakuView?.danmakuCurrentTime()
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "danmakuCurrentTime 失败：$e")
        } finally {
            return currentTime
        }
    }

    /**
     * 显示或隐藏
     */
    fun setDanmaKuVisibility(visible: Boolean) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setDanmaKuVisibility(visible)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setDanmaKuVisibility(visible)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setDanmaKuVisibility 失败：$e")
        }
    }
    /**
     * 弹幕跳转
     */
    fun danmaKuSeekTo(position: Long) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.danmaKuSeekTo(position)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.danmaKuSeekTo(position)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "danmaKuSeekTo 失败：$e")
        }
    }
    /**
     * 设置弹幕滚动速度
     */
    fun setDanmakuSpeed(speed: Float?) {
        if (speed == null) {
            return
        }
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setDanmakuSpeed(speed)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setDanmakuSpeed(speed)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setDanmakuSpeed 失败：$e")
        }
    }
    /**
     * 设置弹幕文字大小
     */
    fun setDanmakuScaleTextSize(fontSize: Int?) {
        if (fontSize == null) {
            return
        }
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setDanmakuScaleTextSize(fontSize)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setDanmakuScaleTextSize(fontSize)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setDanmakuScaleTextSize 失败：$e")
        }
    }
    /**
     * 设置最大显示行数
     */
    fun setDanmakuMaximumLines(areaIndex: Int) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setDanmakuMaximumLines(areaIndex)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setDanmakuMaximumLines(areaIndex)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setDanmakuMaximumLines 失败：$e")
        }
    }

    /**
     * 设置是否启用合并重复弹幕
     */
    fun setDuplicateMergingEnabled(flag: Boolean) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setDuplicateMergingEnabled(flag)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setDuplicateMergingEnabled(flag)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setDuplicateMergingEnabled 失败：$e")
        }
    }


    /**
     * 设置是否显示顶部固定弹幕
     */
    fun setFixedTopDanmakuVisibility(visible: Boolean) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setFixedTopDanmakuVisibility(visible)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setFixedTopDanmakuVisibility(visible)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setFixedTopDanmakuVisibility 失败：$e")
        }
    }

    /**
     * 设置是否显示底部固定弹幕
     */
    fun setFixedBottomDanmakuVisibility(visible: Boolean) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setFixedBottomDanmakuVisibility(visible)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setFixedBottomDanmakuVisibility(visible)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setFixedBottomDanmakuVisibility 失败：$e")
        }
    }

    /**
     * 设置是否显示滚动弹幕
     */
    fun setRollDanmakuVisibility(visible: Boolean) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setRollDanmakuVisibility(visible)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setRollDanmakuVisibility(visible)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setRollDanmakuVisibility 失败：$e")
        }
    }

    /**
     * 设置是否显示特殊弹幕
     */
    fun setSpecialDanmakuVisibility(visible: Boolean) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setSpecialDanmakuVisibility(visible)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setSpecialDanmakuVisibility(visible)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setSpecialDanmakuVisibility 失败：$e")
        }
    }

    /**
     * 是否显示彩色弹幕
     */
    fun setColorsDanmakuVisibility(visible: Boolean) {
        try {
            if (danmakuType == DanmakuType.BILI) {
                biliDanmakuView?.setColorsDanmakuVisibility(visible)
            }
            else if (danmakuType == DanmakuType.AK) {
                akDanmakuView?.setColorsDanmakuVisibility(visible)
            }
        } catch (e: Exception) {
            Log.e(LogTagUtils.DANMAKU_UTILS_LOG_TAG, "setColorsDanmakuVisibility 失败：$e")
        }
    }

}