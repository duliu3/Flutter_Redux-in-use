import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../page/debug/debug_data_page.dart';
import '../page/home_page.dart';
import '../page/login/login_page.dart';
import '../page/login/login_webview.dart';
import '../widget/basic/never_overscroll_indicator.dart';

/**
 * 导航栏
 */
class NavigatorUtils {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
//    if (navigator == null) {
//      try {
//        navigator = Navigator.of(context);
//      } catch (e) {
//        error = true;
//      }
//    }
//
//    if (replace) {
//      ///如果可以返回，清空开始，然后塞入
//      if (!error && navigator.canPop()) {
//        navigator.pushAndRemoveUntil(
//          router,
//          ModalRoute.withName('/'),
//        );
//      } else {
//        ///如果不可返回，直接替换当前
//        navigator.pushReplacement(router);
//      }
//    } else {
//      navigator.push(router);
//    }
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///主页
  static goHome(BuildContext context) {
    if (Config.DEBUG!) {
      print("goHome ");
    }
    Navigator.pushReplacementNamed(context, HomePage.sName);
  }

  ///登录页
  static goLogin(BuildContext context) {
    if (Config.DEBUG!) {
      print("goLogin ");
    }
    Navigator.pushReplacementNamed(context, LoginPage.sName);
  }

  ///公共打开方式
  static NavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => pageContainer(widget, context)));
  }

  ///登陆Web页面
  static Future goLoginWebView(BuildContext context, String url, String title) {
    return NavigatorRouter(context, new LoginWebView(url, title));
  }

  ///Page页面的容器，做一次通用自定义
  static Widget pageContainer(widget, BuildContext context) {
    return MediaQuery(

        ///不受系统字体缩放影响
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        child: NeverOverScrollIndicator(
          needOverload: false,
          child: widget,
        ));
  }


  ///请求数据调试页面
  static goDebugDataPage(BuildContext context) {
    return NavigatorRouter(context, new DebugDataPage());
  }


  ///弹出 dialog
  static Future<T?> showDefaultDialog<T>({
    required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder? builder,
  }) {
    return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(

              ///不受系统字体缩放影响
              data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first)
                  .copyWith(textScaleFactor: 1),
              child: NeverOverScrollIndicator(
                needOverload: false,
                child: new SafeArea(child: builder!(context)),
              ));
        });
  }
}
