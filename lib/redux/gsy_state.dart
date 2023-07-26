import 'package:car_flutter_demo/redux/theme_redux.dart';
import 'package:car_flutter_demo/redux/user_redux.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../model/User.dart';
import 'grey_redux.dart';
import 'locale_redux.dart';
import 'login_redux.dart';
import 'middleware/epic_middleware.dart';

///全局Redux store 的对象，保存State数据
class GSYState {
  ///用户信息
  User? userInfo;

  ///主题数据
  ThemeData? themeData;

  ///语言
  Locale? locale;

  ///当前手机平台默认语言
  Locale? platformLocale;

  ///是否登录
  bool? login;

  ///是否变灰色
  bool grey;

  ///构造方法
  GSYState(
      {this.userInfo,
      this.themeData,
      this.locale,
      this.login,
      this.grey = false});
}

///创建 Reducer
///源码中 Reducer 是一个方法 typedef State Reducer<State>(State state, dynamic action);
///我们自定义了 appReducer 用于创建 store
GSYState appReducer(GSYState state, action) {
  return GSYState(
    userInfo: UserReducer(state.userInfo, action),
    themeData: ThemeDataReducer(state.themeData, action),
    locale: LocaleReducer(state.locale, action),
    login: LoginReducer(state.login, action),
  );
}

final List<Middleware<GSYState>> middleware = [
  EpicMiddleware<GSYState>(loginEpic),
  EpicMiddleware<GSYState>(userInfoEpic),
  EpicMiddleware<GSYState>(oauthEpic),
  UserInfoMiddleware(),
  LoginMiddleware(),
];
