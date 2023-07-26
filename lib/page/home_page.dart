import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';

import '../localization/default_localizations.dart';
import '../style/style_const.dart';
import '../utils/navigator_utils.dart';
import '../widget/gsy_tabbar_widget.dart';
import '../widget/gsy_tabs.dart';
import '../widget/gsy_title_bar.dart';
import '../widget/home_drawer.dart';
import 'common_list_page.dart';
import 'my_page.dart';

class HomePage extends StatefulWidget {
  static final String sName = "home";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<CommonListPageState> homeKey = GlobalKey();
  final GlobalKey<MyPageState> myKey = GlobalKey();

  /// 不退出
  Future<bool> _dialogExitApp(BuildContext context) async {
    ///如果是 android 回到桌面
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: "android.intent.category.HOME",
      );
      await intent.launch();
    }

    return Future.value(false);
  }

  _renderTab(icon, text) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Icon(icon, size: 16.0), Text(text)],
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      _renderTab(GSYICons.MAIN_DT, GSYLocalizations.i18n(context)!.home_dynamic),
      _renderTab(GSYICons.MAIN_MY, GSYLocalizations.i18n(context)!.home_my),
    ];

    ///增加返回按键监听
    return WillPopScope(
      onWillPop: () {
        return _dialogExitApp(context);
      },
      child: GSYTabBarWidget(
        drawer: HomeDrawer(),
        type: TabType.bottom,
        tabItems: tabs,
        tabViews: [
          CommonListPage(key: homeKey),
          MyPage(key: myKey)
        ],
        onDoublePress: (index) {
          switch (index) {
            case 0:
              // homeKey.currentState?.scrollToTop();
              break;
            case 1:
              // myKey.currentState?.scrollToTop();
              break;
          }
        },
        backgroundColor: GSYColors.primarySwatch,
        indicatorColor: GSYColors.white,
        title: GSYTitleBar(
          GSYLocalizations.of(context)!.currentLocalized!.app_name,
          // iconData: GSYICons.MAIN_SEARCH,
          needRightLocalIcon: true,
          // onRightIconPressed: (centerPosition) {
          //   NavigatorUtils.goSearchPage(context, centerPosition);
          // },
        ),
      ),
    );
  }
}
