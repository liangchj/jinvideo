package com.lchj.jinvideo.danmaku.bili

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import com.lchj.jinvideo.danmaku.IJinDanmakuView
import com.lchj.jinvideo.utils.LogTagUtils
import master.flame.danmaku.controller.DanmakuFilters
import master.flame.danmaku.controller.DrawHandler
import master.flame.danmaku.controller.IDanmakuView
import master.flame.danmaku.danmaku.loader.ILoader
import master.flame.danmaku.danmaku.loader.IllegalDataException
import master.flame.danmaku.danmaku.loader.android.DanmakuLoaderFactory
import master.flame.danmaku.danmaku.model.BaseDanmaku
import master.flame.danmaku.danmaku.model.DanmakuTimer
import master.flame.danmaku.danmaku.model.IDanmakus
import master.flame.danmaku.danmaku.model.IDisplayer
import master.flame.danmaku.danmaku.model.android.DanmakuContext
import master.flame.danmaku.danmaku.model.android.Danmakus
import master.flame.danmaku.danmaku.model.android.SpannedCacheStuffer
import master.flame.danmaku.danmaku.parser.BaseDanmakuParser
import master.flame.danmaku.ui.widget.DanmakuView
import org.apache.commons.collections4.MapUtils
import java.io.File
import java.io.FileInputStream
import java.io.InputStream

/**
 * 哔哩哔哩弹幕VIEW（烈焰弹幕使）
 */
class BiliDanmakuView(
    context: Context?,
    private val danmakuUrl: String,
    args: Map<String, Any>
) : IJinDanmakuView {
    private var mDanmakuView : DanmakuView
    //创建弹幕上下文
    private val mContext : DanmakuContext = DanmakuContext.create()
    // 弹幕解析器
    private var mParser: BaseDanmakuParser? = null

    // 弹幕配置
    //设置最大显示行数，默认5行
    private var maxLInes: Int = 5

    // 设置是否禁止重叠
    private var overlappingEnable: Boolean = true
    // 设置描边样式
    private var danmakuStyleStroken: Float = 3f

    // 弹幕字号
    private var fontSize : Float = 1.0f
    // 弹幕速度
    private var danmakuSpeed : Float = 1.0f

    // 解析完是否直接启动
    private var isStart: Boolean = true
    // 是否显示FPS
    private var isShowFPS: Boolean = false
    // 是否显示缓存信息
    private var isShowCache: Boolean = false

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

    init {
        maxLInes = MapUtils.getIntValue(args, "maxLInes", maxLInes)
        overlappingEnable = MapUtils.getBoolean(args, "overlappingEnable", overlappingEnable)
        danmakuStyleStroken = MapUtils.getFloat(args, "danmakuStyleStroken", danmakuStyleStroken)
        fontSize = MapUtils.getFloat(args, "fontSize", fontSize)
        danmakuSpeed = MapUtils.getFloat(args, "danmakuSpeed", danmakuSpeed)
        isStart = MapUtils.getBoolean(args, "isStart", isStart)
        isShowFPS = MapUtils.getBoolean(args, "isShowFPS", isShowFPS)
        isShowCache = MapUtils.getBoolean(args, "isShowCache", isShowCache)
        fixedTopDanmakuVisibility = MapUtils.getBoolean(args, "fixedTopDanmakuVisibility", fixedTopDanmakuVisibility)
        fixedBottomDanmakuVisibility = MapUtils.getBoolean(args, "fixedBottomDanmakuVisibility", fixedBottomDanmakuVisibility)
        rollDanmakuVisibility = MapUtils.getBoolean(args, "rollDanmakuVisibility", rollDanmakuVisibility)
        specialDanmakuVisibility = MapUtils.getBoolean(args, "specialDanmakuVisibility", specialDanmakuVisibility)
        mDuplicateMergingEnable = MapUtils.getBoolean(args, "mDuplicateMergingEnable", mDuplicateMergingEnable)
        colorsDanmakuVisibility = MapUtils.getBoolean(args, "colorsDanmakuVisibility", colorsDanmakuVisibility)

        mDanmakuView = DanmakuView(context)
        setSetting(context)
    }
    override fun getView(): View {
        return mDanmakuView
    }

    /**
     * 销毁view
     */
    override fun dispose() {
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "销毁view")
        try {
            mDanmakuView.release()
        } catch (e: Exception) {
            Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "销毁view失败")
        }
    }

    /**
     * 弹幕设置
     */
    private fun setSetting(context: Context?) {
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "entry setSetting")
        // 设置是否禁止重叠
        val maxLInesPair : Map<Int, Int> = hashMapOf(
            BaseDanmaku.TYPE_SCROLL_RL to maxLInes,
            BaseDanmaku.TYPE_SCROLL_LR to maxLInes, BaseDanmaku.TYPE_FIX_TOP to maxLInes, BaseDanmaku.TYPE_FIX_BOTTOM to maxLInes
        )
        // 设置是否禁止重叠
        val overlappingEnablePair : Map<Int, Boolean> = hashMapOf(BaseDanmaku.TYPE_SCROLL_RL to overlappingEnable, BaseDanmaku.TYPE_FIX_TOP to overlappingEnable)
        mContext.setDanmakuStyle(IDisplayer.DANMAKU_STYLE_STROKEN, danmakuStyleStroken) // 设置描边样式
            .setDuplicateMergingEnabled(mDuplicateMergingEnable) // 设置是否启用合并重复弹幕
            .setFTDanmakuVisibility(fixedTopDanmakuVisibility) // 是否显示顶部弹幕
            .setFBDanmakuVisibility(fixedBottomDanmakuVisibility) // 是否显示底部弹幕
            .setL2RDanmakuVisibility(rollDanmakuVisibility) // 是否显示左右滚动弹幕
            .setR2LDanmakuVisibility(rollDanmakuVisibility) // 是否显示右左滚动弹幕
            .setSpecialDanmakuVisibility(specialDanmakuVisibility) // 是否显示特殊弹幕
            // 设置弹幕滚动速度
            .setScrollSpeedFactor(danmakuSpeed) // 设置弹幕滚动速度系数,只对滚动弹幕有效
            .setScaleTextSize(fontSize) // 弹幕字号
            //设置缓存绘制填充器，默认使用SimpleTextCacheStuffer只支持纯文字显示,
            // 如果需要图文混排请设置SpannedCacheStuffer 如果需要定制其他样式请扩展SimpleTextCacheStuffer|SpannedCacheStuffer
            .setCacheStuffer(SpannedCacheStuffer(), null)
//            .setMaximumLines(maxLInesPair) // 设置最大显示行数
            .setMaximumLines(null) // 设置最大显示行数
            .preventOverlapping(overlappingEnablePa
                    ir) // 设置防弹幕重叠

        if (!colorsDanmakuVisibility) {
            mContext.setColorValueWhiteList(0xFFFFFF)
        }

        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "mDanmakuView not null")
        //mParser = createParser(context!!.openFileInput("C:\\Users\\lcj\\Desktop\\danmu.json"))
        var inStream: InputStream? = null
        if (danmakuUrl.isNotEmpty()) {
            //打开文件
            val file = File(danmakuUrl)
            if (file.exists() && file.isFile) {
                inStream = FileInputStream(file)
            }
        }
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "inStream: ${inStream.toString()}")
        if (inStream != null) {
            mParser = createParser(inStream)
        }

        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "xml："+context!!.resources)
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "mParser：$mParser")
        mDanmakuView.setCallback(object : DrawHandler.Callback {
            override fun updateTimer(timer: DanmakuTimer) {}
            override fun drawingFinished() {}
            override fun danmakuShown(danmaku: BaseDanmaku) {
//                    Log.d("DFM", "danmakuShown(): text=" + danmaku.text);
            }
            override fun prepared() {
                if (isStart) {
                    mDanmakuView.start()
                }
                Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "mDanmakuView start")
            }

        })

        mDanmakuView.onDanmakuClickListener = object : IDanmakuView.OnDanmakuClickListener {
            override fun onDanmakuClick(danmakus: IDanmakus): Boolean {
                Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "onDanmakuClick: danmakus size: ${danmakus.size()}" )
                val latest = danmakus.last()
                if (null != latest) {
                    Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "onDanmakuClick: text of latest danmaku: ${latest.text}")
                    return true
                }
                return false
            }

            override fun onDanmakuLongClick(danmakus: IDanmakus): Boolean {
                return false
            }

            override fun onViewClick(view: IDanmakuView): Boolean {
                Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "点击了弹幕内容：")
                return false
            }
        }
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "mDanmakuView prepare")
        mDanmakuView.prepare(mParser, mContext)
        if (isShowCache) {
            mDanmakuView.showFPS(true)
        }
        if (isShowCache) {
            mDanmakuView.enableDanmakuDrawingCache(true)
        }
    }

    /**
     * 创建解析器
     */
    private fun createParser(stream : InputStream) : BaseDanmakuParser{
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "createParser")
        if (stream == null) {
            Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "stream is null")
            return object : BaseDanmakuParser() {
                override fun parse(): Danmakus {
                    return Danmakus()
                }
            }
        }
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "stream not null，准备读取xml")
        val loader : ILoader = DanmakuLoaderFactory.create(DanmakuLoaderFactory.TAG_BILI)
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "loader加载：$loader")
        try {
            loader.load(stream)
            Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "读取xml")
        } catch (e : IllegalDataException) {
            Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "解析失败")
            e.printStackTrace()
        }
        val parser : BaseDanmakuParser = BiliDanmakuParser()
        val dataSource = loader.dataSource
        parser.load(dataSource)
        Log.d(LogTagUtils.BILI_DANMAKU_LOG_TAG, "parser:$parser")
        return parser
    }

    /**
     * 发送弹幕
     */
    override fun sendDanmaku(isLive: Boolean, text: String) {
        val danmaku = mContext.mDanmakuFactory.createDanmaku(BaseDanmaku.TYPE_SCROLL_RL) ?: return
        danmaku.text = text
        danmaku.padding = 5
        danmaku.priority = 0 // 可能会被各种过滤器过滤并隐藏显示
        danmaku.isLive = isLive
        danmaku.time = mDanmakuView.currentTime + 1200
        danmaku.textSize = 25f * (mParser!!.displayer.density - 0.6f)
        danmaku.textColor = Color.RED
        danmaku.textShadowColor = Color.WHITE
        // danmaku.underlineColor = Color.GREEN;
        danmaku.borderColor = Color.GREEN
        mDanmakuView.addDanmaku(danmaku)
    }

    /**
    * 设置弹幕滚动速度
    */
    override fun setDanmakuSpeed(speed: Float) {
        if (mDanmakuView.isPrepared) {
            try {
                mContext.setScrollSpeedFactor(speed)
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setDanmakuSpeed error: $e")
            }
        }
    }

    /**
     * 设置弹幕文字大小
     */
    override fun setDanmakuScaleTextSize(fontSize: Int) {
        if (mDanmakuView.isPrepared) {
            try {
                mContext.setScaleTextSize(fontSize.toFloat())
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setDanmakuScaleTextSize error: $e")
            }
        }
    }

    /**
     * 设置最大显示行数
     */
    override fun setDanmakuMaximumLines(maxLInes: Int) {
        if (mDanmakuView.isPrepared) {
            try {
                val maxLInesPair : Map<Int, Int> = hashMapOf(BaseDanmaku.TYPE_SCROLL_RL to maxLInes,
                    BaseDanmaku.TYPE_SCROLL_LR to maxLInes, BaseDanmaku.TYPE_FIX_TOP to maxLInes, BaseDanmaku.TYPE_FIX_BOTTOM to maxLInes
                )
                mContext.setMaximumLines(maxLInesPair)
                mDanmakuView.invalidate()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setDanmakuMaximumLines error: $e")
            }
        }
    }

    /**
     * 启动弹幕
     */
    override fun startDanmaku(position: Long?) {
        if (mDanmakuView.isPrepared) {
            try {
                if (position == null) {
                    mDanmakuView.start()
                } else {
                    mDanmakuView.start(position)
                }
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "startDanmaku error: $e")
            }
        }
    }

    /**
     * 暂停弹幕
     */
    override fun pauseDanmaKu() {
        if (mDanmakuView.isPrepared && !mDanmakuView.isPaused) {
            try {
                mDanmakuView.pause()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "pauseDanmaKu error: $e")
            }
        }
    }

    /**
     * 继续弹幕
     */
    override fun resumeDanmaku() {
        if (mDanmakuView.isPrepared && mDanmakuView.isPaused) {
            try {
                mDanmakuView.resume()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "resumeDanmaku error: $e")
            }
        }
    }

    /**
     * 获取当前弹幕时间
     */
    override fun danmakuCurrentTime() : Long {
        var currentTime: Long? = null
        if (mDanmakuView.isPrepared) {
            currentTime =  mDanmakuView.currentTime
        }
        return currentTime ?: 0
    }

    /**
     * 显示或隐藏
     */
    override fun setDanmaKuVisibility(visible: Boolean) {
        if (mDanmakuView.isPrepared) {
            try {
                if (visible) {
                    if (!mDanmakuView.isShown) {
                        mDanmakuView.show()
                    }
                } else {
                    if (mDanmakuView.isShown) {
                        mDanmakuView.hide()
                    }
                }
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setDanmaKuVisibility error: $e")
            }
        }
    }

    /**
     * 弹幕跳转
     */
    override fun danmaKuSeekTo(position: Long) {
        if (mDanmakuView.isPrepared) {
            try {
                mDanmakuView.seekTo(position)
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "danmaKuSeekTo error: $e")
            }
        }
    }

    /**
     * 设置是否启用合并重复弹幕
     */
    override fun setDuplicateMergingEnabled(flag: Boolean) {
        if (mDanmakuView.isPrepared) {
            try {
                mContext.isDuplicateMergingEnabled = flag
                mDanmakuView.invalidate()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setDuplicateMergingEnabled error: $e")
            }
        }
    }

    /**
     * 设置是否显示顶部固定弹幕
     */
    override fun setFixedTopDanmakuVisibility(visible: Boolean) {
        if (mDanmakuView.isPrepared) {
            try {
                mContext.ftDanmakuVisibility = visible
                mDanmakuView.invalidate()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setFTDanmakuVisibility error: $e")
            }
        }
    }

    /**
     * 设置是否显示底部固定弹幕
     */
    override fun setFixedBottomDanmakuVisibility(visible: Boolean) {
        if (mDanmakuView.isPrepared) {
            try {
                mContext.fbDanmakuVisibility = visible
                mDanmakuView.invalidate()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setFBDanmakuVisibility error: $e")
            }
        }
    }

    /**
     * 设置是否显示滚动弹幕
     */
    override fun setRollDanmakuVisibility(visible: Boolean) {
        if (mDanmakuView.isPrepared) {
            try {
                mContext.L2RDanmakuVisibility = visible
                mContext.R2LDanmakuVisibility = visible
                mDanmakuView.invalidate()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setL2RDanmakuVisibility error: $e")
            }
        }
    }

    /**
     * 设置是否显示特殊弹幕
     */
    override fun setSpecialDanmakuVisibility(visible: Boolean) {
        if (mDanmakuView.isPrepared) {
            try {
                mContext.SpecialDanmakuVisibility = visible
                mDanmakuView.invalidate()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setSpecialDanmakuVisibility error: $e")
            }
        }
    }

    /**
     * 是否显示彩色弹幕
     */
    override fun setColorsDanmakuVisibility(visible: Boolean) {
        if (mDanmakuView.isPrepared) {
            try {
                //

                mDanmakuView.invalidate()
            } catch (e: Exception) {
                Log.e(LogTagUtils.BILI_DANMAKU_LOG_TAG, "setColorsDanmakuVisibility error: $e")
            }
        }
    }

}