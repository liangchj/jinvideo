import 'package:flutter/material.dart';
import 'package:jinvideo/model/directory_model.dart';
import 'package:jinvideo/utils/my_icons_utils.dart';
/// 目录widget
class DirectoryItem extends StatelessWidget {
  const DirectoryItem({Key? key, required this.item, this.leadingWidget, this.subtitleWidget, this.onTap, this.trailingWidget, this.contentPadding}) : super(key: key);

  final DirectoryModel item;
  final Widget? leadingWidget;
  final Widget? subtitleWidget;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    Widget defaultLeadingWidget = const Padding(
      padding: EdgeInsets.only(right: 10),
      child: Icon(
        MyIconsUtils.folderFullBackground,
        size: 60,
        color: Colors.black26,
      ),
    );
    Widget defaultSubtitleWidget = Text(
      "${item.fileNumber}个视频",
      style: const TextStyle(fontSize: 12),
    );
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: ListTile(
        horizontalTitleGap: 0,
        contentPadding: contentPadding,
        leading: leadingWidget ?? defaultLeadingWidget,
        title: Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitleWidget ?? defaultSubtitleWidget,
        trailing: trailingWidget,
      ),
    );
  }
}
