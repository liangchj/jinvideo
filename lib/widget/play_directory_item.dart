
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinvideo/model/directory_model.dart';
import 'package:jinvideo/route/app_routes.dart';
import 'package:jinvideo/utils/my_icons_utils.dart';
//
class VideoPlayListItem extends StatelessWidget {
  const VideoPlayListItem({Key? key, required this.playDirectoryModel}) : super(key: key);

  final DirectoryModel playDirectoryModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("点击目录");

      },
      child: ListTile(
        horizontalTitleGap: 0,
        leading: const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(
            MyIconsUtils.folderFullBackground,
            size: 60,
            color: Colors.black26,
          ),
        ),
        title: Text(
          playDirectoryModel.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${playDirectoryModel.fileNumber}个视频",
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
