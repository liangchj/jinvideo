import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinvideo/pages/local_video_drectory_list_page.dart';
import 'package:jinvideo/route/app_pages.dart';
import 'package:jinvideo/route/app_routes.dart';
import 'package:path_provider/path_provider.dart';
import '../model/directory_model.dart';
import '../utils/media_store_utils.dart';

class MediaLibraryPage extends StatefulWidget {
  const MediaLibraryPage({Key? key}) : super(key: key);

  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage>
    with AutomaticKeepAliveClientMixin {
  //["本地媒体", "播放列表", "串流播放", "磁力播放"];
  /*final List<ListTile> _libraryList = [
    ListTile(
      leading: const Icon(Icons.phone_android_rounded),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("本地媒体"),
          Divider()
        ],
      ),
    ),
    ListTile(
      leading: const Icon(Icons.playlist_play_rounded),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("播放列表"),
          Divider()
        ],
      ),
    ),
    ListTile(
      leading: const Icon(Icons.stream_rounded),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("串流播放"),
          Divider()
        ],
      ),
    ),
    ListTile(
      leading: const Icon(Icons.boy_outlined),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("磁力播放"),
          Divider()
        ],
      ),
    ),
  ];*/
  final List<Widget> _libraryList = [
    InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.localVideoDirectory);
      },
      child: const ListTile(
        leading: Icon(Icons.phone_android_rounded),
        title: Text("本地媒体"),
      ),
    ),
    InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.playDirectoryList);
      },
      child: const ListTile(
        leading: Icon(Icons.playlist_play_rounded),
        title: Text("播放列表"),
      ),
    ),
    InkWell(
      onTap: () {
        // Get.to(const DanPage());
      },
      child: const ListTile(
        leading: Icon(Icons.stream_rounded),
        title: Text("串流播放"),
      ),
    ),
    InkWell(
      onTap: () {
        // Get.to(const AKDanmakuTest());
      },
      child: const ListTile(
        leading: Icon(Icons.boy_outlined),
        title: Text("磁力播放"),
      ),
    ),
  ];

  _getMediaStoreVideoDirList() async {
    print("mediaStoreVideoList: start");
      List<DirectoryModel> mediaStoreVideoList =
      await MediaStoreUtils.getMediaStoreVideoDirList();
      print("mediaStoreVideoList: $mediaStoreVideoList");
  }

  _getDir() async {
    var externalStorageDirectory = await getExternalStorageDirectory();
    print(externalStorageDirectory);
    var externalStorageDirectories = await getExternalStorageDirectories();
    print(externalStorageDirectories);

  }

  @override
  Widget build(BuildContext context) {
    print("page build: media library");
    return Scaffold(
      appBar: AppBar(
        title: const Text("媒体库"),
      ),
     /*body: ListView.separated(itemBuilder: (context, index) {
       return InkWell(
         onTap: () => {

         },
         child: _libraryList[index],
       );
     }, separatorBuilder: (context, index) {
       return const Divider();
     }, itemCount: _libraryList.length),*/
      body: ListView(
        children: _libraryList.map((widget) {
          return widget;
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get.to(const ChewieVideoPlayerPage(videoUrl: 'https://qiniu.xiaodengmi.com/a9ac5d86ca3109cb22ed805b1f227074.mp4',));
          // Get.to(DanmakuTest());
        },
        tooltip: 'getVideo',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
