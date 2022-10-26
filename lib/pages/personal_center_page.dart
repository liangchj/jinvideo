
import 'package:flutter/material.dart';

class PersonalCenterPage extends StatefulWidget {
  const PersonalCenterPage({Key? key}) : super(key: key);

  @override
  State<PersonalCenterPage> createState() => _PersonalCenterPageState();
}

class _PersonalCenterPageState extends State<PersonalCenterPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    print("page build: personal center");
    return const Center(
      child: Text("个人中心"),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
