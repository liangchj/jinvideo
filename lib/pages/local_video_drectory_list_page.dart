import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinvideo/getx_controller/video_directory_controller.dart';
import 'package:jinvideo/model/directory_model.dart';
import 'package:jinvideo/route/app_routes.dart';
import 'package:jinvideo/widget/directory_item.dart';
/// 本地视频播放目录列表页面
class LocalVideoDirectoryListPage extends GetView<VideoDirectoryController> {
  const LocalVideoDirectoryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("本地视频列表"),
        actions: [
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var videoDirectoryList = controller.videoDirectoryList;
          return videoDirectoryList.isEmpty
              ? const Center(
                  child: Text("没有视频"),
                )
              : Scrollbar(
                  child: ListView.builder(
                      itemExtent: 66,
                      itemCount: videoDirectoryList.length,
                      itemBuilder: (context, index) {
                        var fileDirectoryModel = videoDirectoryList[index];
                        return DirectoryItem(item: fileDirectoryModel, onTap: () {
                          Map<String, dynamic> params = {"path": fileDirectoryModel.path, "title": "本地播放列表",
                            "directorySourceType": DirectorySourceType.localDirectory, "dirName": fileDirectoryModel.path.split("/").last};
                          Get.toNamed(AppRoutes.videoFileList, arguments: params);
                        },);
                      }));
        }
      }),
    );
  }
}
