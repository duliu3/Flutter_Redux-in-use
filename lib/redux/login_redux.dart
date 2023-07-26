import 'package:car_flutter_demo/redux/gsy_state.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';
import '../dao/dao_result.dart';
import '../dao/user_dao.dart';
import '../db/sql_manager.dart';
import '../utils/common_utils.dart';
import '../utils/navigator_utils.dart';
import 'middleware/epic_store.dart';

final LoginReducer = combineReducers<bool?>([
  TypedReducer<bool?, LoginSuccessAction>(_loginResult) ,
  TypedReducer<bool?, LogoutAction>(_logoutResult),
]);

bool? _loginResult(bool? result, LoginSuccessAction action) {
  if (action.success == true) {
    NavigatorUtils.goHome(action.context);
  }
  return action.success;
}

bool? _logoutResult(bool? result, LogoutAction action) {
  return true;
}

class LoginSuccessAction {
  final BuildContext context;
  final bool success;

  LoginSuccessAction(this.context, this.success);
}

class LogoutAction {
  final BuildContext context;

  LogoutAction(this.context);
}

class LoginAction {
  final BuildContext context;
  final String? username;
  final String? password;

  LoginAction(this.context, this.username, this.password);
}

class OAuthAction {
  final BuildContext context;
  final String code;

  OAuthAction(this.context, this.code);
}

class LoginMiddleware implements MiddlewareClass<GSYState> {
  @override
  void call(Store<GSYState> store, dynamic action, NextDispatcher next) {
    if (action is LogoutAction) {
      UserDao.clearAll(store);
      // CookieManager().clearCookies();
      SqlManager.close();
      NavigatorUtils.goLogin(action.context);
    }
    // Make sure to forward actions to the next middleware in the chain!
    next(action);
  }
}

Stream<dynamic> loginEpic(Stream<dynamic> actions, EpicStore<GSYState> store) {
  Stream<dynamic> _loginIn(
      LoginAction action, EpicStore<GSYState> store) async* {
    CommonUtils.showLoadingDialog(action.context);
    // var res = await UserDao.login(
    //     action.username!.trim(), action.password!.trim(), store);
    // await UserDao.oauth(action.code, store);
    //todo 具体登录请求
    var res = DataResult(null, true);
    Navigator.pop(action.context);
    yield LoginSuccessAction(action.context, (res != null && res.result));
  }
  return actions
      .whereType<LoginAction>()
      .switchMap((action) => _loginIn(action, store));
}

Stream<dynamic> oauthEpic(Stream<dynamic> actions, EpicStore<GSYState> store) {
  Stream<dynamic> _loginIn(
      OAuthAction action, EpicStore<GSYState> store) async* {
    CommonUtils.showLoadingDialog(action.context);
    var res = await UserDao.oauth(action.code, store);
    Navigator.pop(action.context);
    yield LoginSuccessAction(action.context, (res != null && res.result));
  }
  return actions
      .whereType<OAuthAction>()
      .switchMap((action) => _loginIn(action, store));
}
