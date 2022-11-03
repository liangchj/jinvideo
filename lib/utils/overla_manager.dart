
import 'package:flutter/material.dart';

class OverlayManager {
  OverlayManager._privateConstructor(bool status);

  static final OverlayManager _instance =
  OverlayManager._privateConstructor(false);
  OverlayEntry? _entry;
  BuildContext? _context;

  //初始化单例,在根入口完成最好
  static initInstance(BuildContext context) {
    _instance._context = context;
    return _instance;
  }
  //获取单例
  static OverlayManager getInstance() {
    assert(_instance._context != null);
    return _instance;
  }

  showOverlay(bool show, {Widget widget = const Text('暂无内容')}) {
    assert(_context != null);
    if (show) {
      _entry = _handleEntry(widget);
      Overlay.of(_context!)?.insert(_entry!);
    } else {
      if (_entry!.mounted) {
        _entry!.remove();
      }
    }
  }

  OverlayEntry _handleEntry(Widget widget) {
    if (_entry != null) {
      if (_entry!.mounted) {
        _entry!.remove();
      }
    }
    OverlayEntry entry = OverlayEntry(builder: (context) => widget);
    return entry;
  }
}
