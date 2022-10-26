import 'package:get/get.dart';
import 'package:jinvideo/getx_controller/play_directory_controller.dart';
import 'package:jinvideo/getx_controller/search_barrage_subtitle_controller.dart';
import 'package:jinvideo/getx_controller/video_directory_controller.dart';
import 'package:jinvideo/getx_controller/video_file_controller.dart';
import 'package:jinvideo/pages/local_video_drectory_list_page.dart';
import 'package:jinvideo/pages/play_directory_list_page.dart';
import 'package:jinvideo/pages/search_barrage_subtitle_page.dart';
import 'package:jinvideo/pages/video_file_list_page.dart';
import 'package:jinvideo/route/app_routes.dart';

import '../main.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.index, page: () => const JinVideoApp()),
    GetPage(
        name: AppRoutes.localVideoDirectory,
        page: () => const LocalVideoDirectoryListPage(),
        binding: BindingsBuilder(
            () => Get.lazyPut(() => VideoDirectoryController()))),
    GetPage(
        name: AppRoutes.videoFileList,
        page: () => const VideoFileListPage(),
        bindings: [
          BindingsBuilder(
                  () => Get.lazyPut(() => VideoFileController())),
          BindingsBuilder(
                  () => Get.lazyPut(() => PlayDirectoryListController()))
        ],
        /*binding: BindingsBuilder(
                () => Get.lazyPut(() => VideoFileController()))*/),
    GetPage(
        name: AppRoutes.playDirectoryList,
        page: () => const PlayDirectoryListPage(),
        binding: BindingsBuilder(
                () => Get.lazyPut(() => PlayDirectoryListController()))),

    GetPage(
        name: AppRoutes.searchBarrageSubtitle,
        page: () => const SearchBarrageSubtitlePage(),
        binding: BindingsBuilder(
                () => Get.lazyPut(() => SearchBarrageSubtitleController()))),
  ];
}
