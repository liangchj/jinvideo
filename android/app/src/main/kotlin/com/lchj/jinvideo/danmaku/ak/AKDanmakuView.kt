package com.lchj.jinvideo.danmaku.ak

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import android.view.View
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.kuaishou.akdanmaku.DanmakuConfig
import com.kuaishou.akdanmaku.data.DanmakuItemData
import com.kuaishou.akdanmaku.ecs.component.action.Actions
import com.kuaishou.akdanmaku.ecs.component.filter.*
import com.kuaishou.akdanmaku.render.SimpleRenderer
import com.kuaishou.akdanmaku.ui.DanmakuPlayer
import com.kuaishou.akdanmaku.ui.DanmakuView
import com.lchj.jinvideo.danmaku.IJinDanmakuView
import com.lchj.jinvideo.utils.LogTagUtils
import org.apache.commons.collections4.MapUtils
import java.io.File
import java.io.FileInputStream
import kotlin.random.Random

class AKDanmakuView(context: Context?, private val danmakuUrl: String, args: Map<String, Any>) :
    IJinDanmakuView {
    companion object {
        private const val MSG_START = 1001
        private const val MSG_UPDATE_DATA = 2001
    }

    private val danmakuView: DanmakuView //by lazy { DanmakuView(context) }
    private var danmakuPlayer: DanmakuPlayer
    private val simpleRenderer = SimpleRenderer()

    private val mainHandler = object : Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            when (msg.what) {
                MSG_START -> startDanmaku(null)
                MSG_UPDATE_DATA -> updateDanmakuData()
            }
        }
    }
    // 颜色过滤
    private val colorFilter = TextColorFilter()

    // 数据过滤
    private var dataFilters = emptyMap<Int, DanmakuFilter>()

    // 弹幕配置
    private var config : DanmakuConfig

    // 设置是否禁止重叠
    private var overlappingEnable: Boolean = true
    // 弹幕字号
    private var fontSize : Float = 1.0f
    // 弹幕速度
    private var danmakuSpeed : Float = 1.0f
    /**
     * 弹幕显示隐藏设置
     */
    // 是否显示顶部弹幕
    private var fixedTopDanmakuVisibility: Boolean = true
    // 是否显示底部弹幕
    private var fixedBottomDanmakuVisibility: Boolean = true
    // 是否显示滚动弹幕
    private var rollDanmakuVisibility: Boolean = true
    // 是否显示特殊弹幕
    private var specialDanmakuVisibility: Boolean = true
    // 是否启用合并重复弹幕
    private var mDuplicateMergingEnable: Boolean = false

    // 是否显示彩色弹幕
    private var colorsDanmakuVisibility: Boolean = true

    // 解析完是否直接启动
    private var isStart: Boolean = true

    init {
        overlappingEnable = MapUtils.getBoolean(args, "overlappingEnable", overlappingEnable)
        fontSize = MapUtils.getFloat(args, "fontSize", fontSize)
        danmakuSpeed = MapUtils.getFloat(args, "danmakuSpeed", danmakuSpeed)
        fixedTopDanmakuVisibility = MapUtils.getBoolean(args, "fixedTopDanmakuVisibility", fixedTopDanmakuVisibility)
        fixedBottomDanmakuVisibility = MapUtils.getBoolean(args, "fixedBottomDanmakuVisibility", fixedBottomDanmakuVisibility)
        rollDanmakuVisibility = MapUtils.getBoolean(args, "rollDanmakuVisibility", rollDanmakuVisibility)
        specialDanmakuVisibility = MapUtils.getBoolean(args, "specialDanmakuVisibility", specialDanmakuVisibility)
        mDuplicateMergingEnable = MapUtils.getBoolean(args, "duplicateMergingEnabled", mDuplicateMergingEnable)
        colorsDanmakuVisibility = MapUtils.getBoolean(args, "colorsDanmakuVisibility", colorsDanmakuVisibility)
        isStart = MapUtils.getBoolean(args, "isStart", isStart)
        config = DanmakuConfig().apply {
            dataFilter = createDataFilters()
            dataFilters = dataFilter.associateBy { it.filterParams }
            layoutFilter = createLayoutFilters()
            textSizeScale = fontSize
            allowOverlap = overlappingEnable
            timeFactor = danmakuSpeed
        }
        if (!fixedTopDanmakuVisibility) {
            (dataFilters[DanmakuFilters.FILTER_TYPE_TYPE] as? TypeFilter)?.let { filter ->
                filter.addFilterItem(DanmakuItemData.DANMAKU_MODE_CENTER_TOP)
                config.updateFilter()
            }
        }
        if (!fixedBottomDanmakuVisibility) {
            (dataFilters[DanmakuFilters.FILTER_TYPE_TYPE] as? TypeFilter)?.let { filter ->
                filter.addFilterItem(DanmakuItemData.DANMAKU_MODE_CENTER_BOTTOM)
                config.updateFilter()
            }
        }
        if (!rollDanmakuVisibility) {
            (dataFilters[DanmakuFilters.FILTER_TYPE_TYPE] as? TypeFilter)?.let { filter ->
                filter.addFilterItem(DanmakuItemData.DANMAKU_MODE_ROLLING)
                config.updateFilter()
            }
        }
        if (!colorsDanmakuVisibility) {
            colorFilter.filterColor.clear()
            colorFilter.filterColor.add(0xFFFFFF)
            config.updateFilter()
        }
        danmakuView = DanmakuView(context)
        danmakuPlayer = DanmakuPlayer(simpleRenderer).also {
            it.bindView(danmakuView)
        }
        mainHandler.sendEmptyMessageDelayed(MSG_UPDATE_DATA, 2000)
        if (isStart) {
            mainHandler.sendEmptyMessageDelayed(MSG_START, 2500)
        }
    }

    override fun getView(): View {
        return danmakuView
    }

    override fun dispose() {
        Log.d(LogTagUtils.AK_DANMAKU_LOG_TAG, "销毁view")
        try {
            danmakuPlayer.release()
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "销毁弹幕VIEW出错：$e")
        }
    }
    /**
     * 发送弹幕
     */
    override fun sendDanmaku(isLive: Boolean, text: String) {
        val danmaku = DanmakuItemData(
            Random.nextLong(),
            danmakuPlayer.getCurrentTimeMs() + 500,
            //      "这是我自己发送的内容(*^▽^*)😄",
            // "[2,1,\"1-1\",4.5,\"拒绝跟你们合影\",7,6,8,5,500,0,true,\"黑体\",1]",
            text,
            DanmakuItemData.DANMAKU_MODE_ROLLING,
            25,
            Color.WHITE,
            9,
            DanmakuItemData.DANMAKU_STYLE_ICON_UP,
            9
        )
        val item = danmakuPlayer.obtainItem(danmaku)
        val sequenceAction = Actions.sequence(
            Actions.rotateBy(360f, 1000L),
            Actions.scaleTo(1.5f, 1.5f, 500L),
            Actions.scaleTo(0.8f, 0.8f, 300L)
        )
        item.addAction(
            Actions.moveBy(0f, 300f, 1735L),
            sequenceAction,
            Actions.sequence(Actions.fadeOut(500L), Actions.fadeIn(300L))
        )
        danmakuPlayer.send(item)
    }
    /**
     * 从文件中加载弹幕数据
     */
    private fun updateDanmakuData() {
        Thread {
            Log.d(LogTagUtils.AK_DANMAKU_LOG_TAG, "开始加载数据")
            var total: Long = 0
            try {
                var jsonString = ""
                if (danmakuUrl.isNotEmpty()) {
                    //打开文件
                    val file = File(danmakuUrl)
                    if (file.exists() && file.isFile) {
                        jsonString = FileInputStream(file).bufferedReader().use { it.readText() }
                    }
                }
                //val jsonString = "" //assets.open("test_danmaku_data.json").bufferedReader().use { it.readText() }
                val type = object : TypeToken<List<DanmakuItemData>>() {}.type
                Log.d(LogTagUtils.AK_DANMAKU_LOG_TAG, "开始解析数据")
                val dataList = Gson().fromJson<List<DanmakuItemData>>(jsonString, type)
                total = dataList.size.toLong()
                danmakuPlayer.updateData(dataList)
            } catch (e: Exception) {
                Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "加载数据失败: $e")
            }
            Log.d(LogTagUtils.AK_DANMAKU_LOG_TAG, "数据已加载(count = $total)")
        }.start()
    }

    /**
     * 创建过滤
     */
    private fun createDataFilters(): List<DanmakuDataFilter> =
        listOf(
            TypeFilter(),
            colorFilter,
            UserIdFilter(),
            GuestFilter(),
            BlockedTextFilter { it == 0L },
            DuplicateMergedFilter()
        )

    private fun createLayoutFilters(): List<DanmakuLayoutFilter> = emptyList()
    /**
     * 设置过滤类型
     */
    private fun switchTypeFilter(show: Boolean, type: Int) {
        (dataFilters[DanmakuFilters.FILTER_TYPE_TYPE] as? TypeFilter)?.let { filter ->
            if (show) filter.removeFilterItem(type)
            else filter.addFilterItem(type)
            config.updateFilter()
            Log.w(LogTagUtils.AK_DANMAKU_LOG_TAG, "[Controller] updateFilter visibility: ${config.visibility}")
            danmakuPlayer.updateConfig(config)
        }
    }

    /**
     * 设置是否启用合并重复弹幕
     */
    override fun setDuplicateMergingEnabled(flag: Boolean) {

    }

    /**
     * 设置是否显示顶部弹幕
     */
    override fun setFixedTopDanmakuVisibility(visible: Boolean) {
        try {
            switchTypeFilter(visible, DanmakuItemData.DANMAKU_MODE_CENTER_TOP)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "setFTDanmakuVisibility error: $e")
        }
    }
    /**
     * 设置是否显示底部弹幕
     */
    override fun setFixedBottomDanmakuVisibility(visible: Boolean) {
        try {
            switchTypeFilter(visible, DanmakuItemData.DANMAKU_MODE_CENTER_BOTTOM)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "setFBDanmakuVisibility error: $e")
        }
    }

    /**
     * 设置是否显示左右滚动弹幕
     */
    override fun setRollDanmakuVisibility(visible: Boolean) {
        try {
            switchTypeFilter(visible, DanmakuItemData.DANMAKU_MODE_ROLLING)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "setRollDanmakuVisibility error: $e")
        }
    }
    /**
     * 设置是否显示特殊弹幕
     */
    override fun setSpecialDanmakuVisibility(visible: Boolean) {
        // AK没有此功能
    }

    /**
     * 是否显示彩色弹幕
     */
    override fun setColorsDanmakuVisibility(visible: Boolean) {
        try {
            colorFilter.filterColor.clear()
            if (!visible) {
                colorFilter.filterColor.add(0xFFFFFF)
            }
            config.updateFilter()
            danmakuPlayer.updateConfig(config)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "setColorsDanmakuVisibility error: $e")
        }
    }

    /**
     * 开启弹幕
     */
    override fun startDanmaku(position: Long?) {
        try {
            danmakuPlayer.start(config)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "startDanmaku error: $e")
        }
    }

    /**
     * 暂停弹幕
     */
    override fun pauseDanmaKu() {
        try {
            danmakuPlayer.pause()
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "pauseDanmaKu error: $e")
        }
    }

    /**
     * 继续弹幕
     */
    override fun resumeDanmaku() {
        try {
            danmakuPlayer.start()
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "resumeDanmaku error: $e")
        }
    }

    /**
     * 获取当前弹幕时间
     */
    override fun danmakuCurrentTime(): Long {
        var currentTime: Long? = null
        try {
            currentTime = danmakuPlayer.getCurrentTimeMs()
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "danmakuCurrentTime error: $e")
        }
        return currentTime ?: 0
    }

    /**
     * 弹幕跳转（毫秒）
     */
    override fun danmaKuSeekTo(positionMills: Long) {
        try {
            danmakuPlayer.seekTo(positionMills)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "danmaKuSeekTo error: $e")
        }
    }

    /**
     * 显示/隐藏弹幕
     */
    override fun setDanmaKuVisibility(visible: Boolean) {
        try {
            config = config.copy(visibility = visible)
            danmakuPlayer.updateConfig(config)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "setDanmaKuVisibility error: $e")
        }
    }

    /**
     * 更新弹幕滚动速度（接收到的为已经计算好的速度）
     * 慢、较慢、正常、较快、快
     * （等级下标 + 1） / 3
     */
    override fun setDanmakuSpeed(speed: Float) {
        try {
            danmakuPlayer.updatePlaySpeed(speed)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "setDanmakuSpeed error: $e")
        }
    }

    /**
     * 设置弹幕文字大小
     */
    override fun setDanmakuScaleTextSize(fontSize: Int) {
        try {
            var fontSizeRatio = (fontSize / 100).toFloat()
            config = config.copy(textSizeScale = fontSizeRatio)
            danmakuPlayer.updateConfig(config)
        } catch (e: Exception) {
            Log.e(LogTagUtils.AK_DANMAKU_LOG_TAG, "setDanmakuScaleTextSize error: $e")
        }
    }

    /**
     * 设置最大显示行数
     */
    override fun setDanmakuMaximumLines(areaIndex: Int) {
        TODO("Not yet implemented")
    }

}