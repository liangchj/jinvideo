
import 'package:get/get.dart';
import 'package:jinvideo/data/media_data.dart';
import 'package:jinvideo/db/cache_const.dart';
import 'package:jinvideo/db/mmkv_cache.dart';
import 'package:jinvideo/model/directory_model.dart';
import 'package:jinvideo/model/file_model.dart';
import 'package:jinvideo/utils/file_directory_utils.dart';
/// 视频文件Controller
class VideoFileController extends GetxController {
  var loading = true.obs;
  var videoFileList = <FileModel>[].obs;
  /*@override
  void onInit() {
    super.onInit();
  }*/

  Future<void> getVideoFileList(String path, DirectorySourceType directorySourceType) async {
    try {
      loading(true);
      videoFileList.clear();
      if (directorySourceType == DirectorySourceType.playDirectory) {
        videoFileList.clear();
        if (MediaData.playFileListMap.containsKey(CacheConst.cachePrev + path)) {
          videoFileList.addAll(MediaData.playFileListMap[CacheConst.cachePrev + path] ?? []);
        } else {
          /// 从存储中获取播放文件列表（path相当于key）
          String? playFileListJson = PlayListMMKVCache.getInstance().getString(CacheConst.cachePrev + path);
          if (playFileListJson != null && playFileListJson.isNotEmpty) {
            /// 转换为list
            videoFileList.assignAll(fileModelListFromJson(playFileListJson));
            videoFileList.sort((FileModel a, FileModel b) {
              return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            });
          }
          MediaData.playFileListMap[CacheConst.cachePrev + path] = videoFileList;
        }
        for (var element in videoFileList) {
          element.fileSourceType = FileSourceType.playListFile;
          element.directory = CacheConst.cachePrev + path;
          element.barragePath = DanmakuMMKVCache.getInstance().getString(CacheConst.cachePrev + element.path);
        }
      } else {
        var fileList = await FileDirectoryUtils.getFileListByPath(path: path, fileFormat: FileFormat.video);
        if (fileList.isNotEmpty) {
          for (var element in fileList) {
            element.barragePath = DanmakuMMKVCache.getInstance().getString(CacheConst.cachePrev + element.path);
          }
          videoFileList.assignAll(fileList);
        }
      }
    } finally {
      loading(false);
    }
  }
  /// 排序
  void reorder() {
    videoFileList.sort((FileModel a, FileModel b) {
      return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
    });
    videoFileList.refresh();
  }

  /// 从播放列表中移除视频
  bool removeVideoFromPlayDirectory(FileModel fileModel) {
    bool remove = videoFileList.remove(fileModel);
    if (remove) {
      MediaData.playFileListMap[fileModel.directory] = videoFileList;
      PlayListMMKVCache.getInstance().setString(fileModel.directory, fileModelListToJson(videoFileList));
    }
    return remove;
  }
}