
import 'dart:async';

import 'package:car_flutter_demo/main.dart';
import 'package:car_flutter_demo/page/debug/debug_label.dart';
import 'package:car_flutter_demo/page/home_page.dart';
import 'package:car_flutter_demo/page/login/login_page.dart';
import 'package:car_flutter_demo/page/welcome_page.dart';
import 'package:car_flutter_demo/redux/gsy_state.dart';
import 'package:car_flutter_demo/style/style_const.dart';
import 'package:car_flutter_demo/utils/common_utils.dart';
import 'package:car_flutter_demo/utils/navigator_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:redux/redux.dart';

import 'event/http_error_event.dart';
import 'event/index.dart';
import 'localization/default_localizations.dart';
import 'localization/localizations_delegate.dart';
import 'model/User.dart';
import 'network/code.dart';

class FlutterReduxApp extends StatefulWidget {
  @override
  _FlutterReduxAppState createState() => _FlutterReduxAppState();
}


class _FlutterReduxAppState extends State<FlutterReduxApp>
    with HttpErrorListener {
  /// initialState 初始化 State
  final store = Store<GSYState>(
    appReducer,

    ///拦截器
    middleware: middleware,

    ///初始化数据
    initialState: GSYState(
        userInfo: User.empty(),
        login: false,
        themeData: CommonUtils.getThemeData(GSYColors.primarySwatch),
        locale: Locale('zh', 'CH')),
  );

  ColorFilter greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);


  NavigatorObserver navigatorObserver = NavigatorObserver();


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      /// 通过 with NavigatorObserver ，在这里可以获取可以往上获取到
      /// MaterialApp 和 StoreProvider 的 context
      /// 还可以获取到 navigator;
      /// 比如在这里增加一个监听，如果 token 失效就退回登陆页。
      navigatorObserver.navigator!.context;
      navigatorObserver.navigator;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 使用 flutter_redux 做全局状态共享
    /// 通过 StoreProvider 应用 store
    return StoreProvider(
      store: store,
      child: StoreBuilder<GSYState>(builder: (context, store) {
        ///使用 StoreBuilder 获取 store 中的 theme 、locale
        store.state.platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
        Widget app = MaterialApp(
            navigatorKey: navKey,
            ///多语言实现代理
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              CustomLocationsDelegate.delegate,
            ],
            supportedLocales: [
              store.state.locale ?? store.state.platformLocale!
            ],
            locale: store.state.locale,
            theme: store.state.themeData,
            navigatorObservers: [navigatorObserver],

            ///命名式路由
            routes: {
              WelcomePage.sName: (context) {
                DebugLabel.showDebugLabel(context);
                return const WelcomePage();
              },
              HomePage.sName: (context) {
                return NavigatorUtils.pageContainer(HomePage(), context);
              },
              LoginPage.sName: (context) {
                return NavigatorUtils.pageContainer(LoginPage(), context);
              },
            });

        if (store.state.grey) {
          ///mode one
          app = ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation),
              child: app);
          ///mode tow
          // app = ColorFiltered(
          //     colorFilter: greyscale,
          //     child: app);
        }

        return app;
      }),
    );
  }

}

mixin HttpErrorListener on State<FlutterReduxApp> {
  StreamSubscription? stream;

  GlobalKey<NavigatorState> navKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    stream = eventBus.on<HttpErrorEvent>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (stream != null) {
      stream!.cancel();
      stream = null;
    }
  }

  ///网络错误提醒
  errorHandleFunction(int? code, message) {
    var context = navKey.currentContext!;
    switch (code) {
      case Code.NETWORK_ERROR:
        showToast(GSYLocalizations.i18n(context)!.network_error);
        break;
      case 401:
        showToast(GSYLocalizations.i18n(context)!.network_error_401);
        break;
      case 403:
        showToast(GSYLocalizations.i18n(context)!.network_error_403);
        break;
      case 404:
        showToast(GSYLocalizations.i18n(context)!.network_error_404);
        break;
      case Code.NETWORK_TIMEOUT:
      //超时
        showToast(GSYLocalizations.i18n(context)!.network_error_timeout);
        break;
      default:
        showToast(GSYLocalizations.i18n(context)!.network_error_unknown +
            " " +
            message);
        break;
    }
  }

  showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG);
  }
}

