import 'package:get/get.dart';
import 'package:jinvideo/data/media_data.dart';
import 'package:jinvideo/model/directory_model.dart';
import 'package:jinvideo/utils/media_store_utils.dart';
/// 视频目录Controller
class VideoDirectoryController extends GetxController {
  var loading = true.obs;
  var videoDirectoryList = <DirectoryModel>[].obs;

  @override
  void onInit() {
    print("VideoDirectoryController init：$videoDirectoryList");
    getVideoDirectoryList();
    super.onInit();
  }
  /// 获取视频目录列表
  void getVideoDirectoryList() async {
    try {
      loading(true);
      if (MediaData.loadedLocalDirectoryList) {
        videoDirectoryList.clear();
        videoDirectoryList.addAll(MediaData.localDirectoryList);
      } else {
        var mediaStoreVideoDirList = await MediaStoreUtils.getMediaStoreVideoDirList();
        if (mediaStoreVideoDirList.isNotEmpty) {
          videoDirectoryList.assignAll(mediaStoreVideoDirList);
          videoDirectoryList.sort((DirectoryModel a, DirectoryModel b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        }
        MediaData.localDirectoryList = videoDirectoryList;
      }

    } finally {
      loading(false);
    }
  }
}
