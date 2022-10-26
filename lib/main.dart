import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jinvideo/db/mmkv_cache.dart';
import 'package:jinvideo/getx_controller/my_file_selector_controller.dart';
import 'package:jinvideo/getx_controller/video_directory_controller.dart';
import 'package:jinvideo/pages/home_page.dart';
import 'package:jinvideo/pages/media_library_page.dart';
import 'package:jinvideo/pages/personal_center_page.dart';
import 'package:jinvideo/route/app_pages.dart';
import 'package:jinvideo/utils/permission_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  MMKVCacheInit.preInit();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,   // 竖屏 Portrait 模式
    DeviceOrientation.portraitDown, ])
      .then((_) {
    runApp(GetMaterialApp(
      initialRoute: "/",
      getPages: AppPages.pages,
      home: const JinVideoApp(),
      builder: EasyLoading.init(),
    ));
  });
  /*runApp(GetMaterialApp(
    initialRoute: "/",
    getPages: AppPages.pages,
    home: const JinVideoApp(),
    builder: EasyLoading.init(),
  ));*/
}

class JinVideoApp extends StatelessWidget {
  const JinVideoApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const JinVideoAppPage(),
    );
  }
}

class JinVideoAppPage extends StatefulWidget {
  const JinVideoAppPage({Key? key}) : super(key: key);
  static const List<BottomNavigationBarItem> bottomTabList = [
    BottomNavigationBarItem(label: "首页", icon: Icon(Icons.home)),
    BottomNavigationBarItem(label: "媒体库", icon: Icon(Icons.video_collection_rounded)),
    BottomNavigationBarItem(label: "我的", icon: Icon(Icons.people_alt_rounded)),
  ];
  static const List<Widget> tabPageList = [
    HomePage(),
    MediaLibraryPage(),
    PersonalCenterPage()
  ];
  @override
  State<JinVideoAppPage> createState() => _JinVideoAppPageState();
}

class _JinVideoAppPageState extends State<JinVideoAppPage> {
  /// 是否已经申请权限
  bool _requestPermission = false;
  static int _currentIndex = 0;
  final PageController _tabController = PageController(initialPage: _currentIndex);
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }
  @override
  Widget build(BuildContext context) {
    if (!_requestPermission) {
      // List<Permission> permissionList = [Permission.storage, Permission.manageExternalStorage];
      List<Permission> permissionList = [Permission.storage];
      PermissionUtils.checkPermission(permissionList: permissionList, onPermissionCallback: (flag) {
        print("flag: $flag");
        setState((){
          _requestPermission = flag;
        });
      });
    }
    return Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: JinVideoAppPage.tabPageList,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: JinVideoAppPage.bottomTabList,
          selectedFontSize: 12.0,
          onTap: (pageIndex) {
            if (pageIndex != _currentIndex) {
              _tabController.jumpToPage(pageIndex);
              setState(()=>{
                _currentIndex = pageIndex
              });
            }
          },
        )
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
