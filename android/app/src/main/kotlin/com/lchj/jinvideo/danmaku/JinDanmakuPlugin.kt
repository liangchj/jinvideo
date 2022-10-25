package com.lchj.jinvideo.danmaku

import com.lchj.jinvideo.utils.MethodChannelUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry

class JinDanmakuPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger : BinaryMessenger = binding.binaryMessenger
        binding
            .platformViewRegistry
            .registerViewFactory(MethodChannelUtils.METHOD_CHANNEL_DANMAKU_VIEW, JinDanmakuViewFactory(messenger))

    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            registrar
                .platformViewRegistry()
                .registerViewFactory(MethodChannelUtils.METHOD_CHANNEL_DANMAKU_VIEW, JinDanmakuViewFactory(registrar.messenger()))
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        //TODO("Not yet implemented")
    }
}