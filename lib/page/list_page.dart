import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../redux/gsy_state.dart';
import '../style/style_const.dart';
import '../widget/pull/nested/gsy_nested_pull_load_widget.dart';

class MyPage extends StatefulWidget {
  MyPage({super.key});
  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  final ScrollController scrollController = ScrollController();

  String beStaredCount = '---';

  Color notifyColor = GSYColors.subTextColor;

  Store<GSYState>? _getStore() {
    return StoreProvider.of(context);
  }

  ///从全局状态中获取我的用户名
  _getUserName() {
    if (_getStore()?.state.userInfo == null) {
      return null;
    }
    return _getStore()?.state.userInfo?.login;
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GSYState>(
      builder: (context, store) {
        return Container();
      },
    );
  }
}
