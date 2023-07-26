import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/config.dart';
import '../../local/local_storage.dart';
import '../../localization/default_localizations.dart';
import '../../network/address.dart';
import '../../redux/gsy_state.dart';
import '../../redux/login_redux.dart';
import '../../style/style_const.dart';
import '../../utils/common_utils.dart';
import '../../utils/navigator_utils.dart';
import '../../widget/gsy_flex_button.dart';
import '../../widget/gsy_input_widget.dart';

class LoginPage extends StatefulWidget {
  static final String sName = "login";

  @override
  State createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> with LoginBLoC {
  @override
  Widget build(BuildContext context) {
    /// 触摸收起键盘
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Container(
          color: Theme.of(context).primaryColor,
          child: Stack(children: <Widget>[
            Center(
              ///防止overFlow的现象
              child: SafeArea(
                ///同时弹出键盘不遮挡
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: GSYColors.cardWhite,
                    margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, top: 40.0, right: 30.0, bottom: 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GSYInputWidget(
                            hintText: GSYLocalizations.i18n(context)!
                                .login_username_hint_text,
                            iconData: GSYICons.LOGIN_USER,
                            onChanged: (String value) {
                              _userName = value;
                            },
                            controller: userController,
                          ),
                          Padding(padding: EdgeInsets.all(10.0)),
                          GSYInputWidget(
                            hintText: GSYLocalizations.i18n(context)!
                                .login_password_hint_text,
                            iconData: GSYICons.LOGIN_PW,
                            obscureText: true,
                            onChanged: (String value) {
                              _password = value;
                            },
                            controller: pwController,
                          ),
                          Padding(padding: EdgeInsets.all(10.0)),
                          Container(
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: GSYFlexButton(
                                    text: GSYLocalizations.i18n(context)!
                                        .login_text,
                                    color: Theme.of(context).primaryColor,
                                    textColor: GSYColors.textWhite,
                                    fontSize: 16,
                                    onPress: loginIn,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: GSYFlexButton(
                                    text: GSYLocalizations.i18n(context)!
                                        .oauth_text,
                                    color: Theme.of(context).primaryColor,
                                    textColor: GSYColors.textWhite,
                                    fontSize: 16,
                                    onPress: NavigatorUtils.goHome(context),
                                    // todo 跳过网页登录流程
                                    // oauthLogin,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(15.0)),
                          InkWell(
                            onTap: () {
                              CommonUtils.showLanguageDialog(context);
                            },
                            child: Text(
                              GSYLocalizations.i18n(context)!.switch_language,
                              style: TextStyle(color: GSYColors.subTextColor),
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(15.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

mixin LoginBLoC on State<LoginPage> {
  final TextEditingController userController = TextEditingController();

  final TextEditingController pwController = TextEditingController();

  String? _userName = "";

  String? _password = "";

  @override
  void initState() {
    super.initState();
    initParams();
  }

  @override
  void dispose() {
    super.dispose();
    userController.removeListener(_usernameChange);
    pwController.removeListener(_passwordChange);
  }

  _usernameChange() {
    _userName = userController.text;
  }

  _passwordChange() {
    _password = pwController.text;
  }

  initParams() async {
    _userName = await LocalStorage.get(Config.USER_NAME_KEY);
    _password = await LocalStorage.get(Config.PW_KEY);
    userController.value = TextEditingValue(text: _userName ?? "");
    pwController.value = TextEditingValue(text: _password ?? "");
  }

//  正常登录流程
  loginIn() async {
    // Fluttertoast.showToast(
    //     msg: GSYLocalizations.i18n(context)!.login_success,
    //     gravity: ToastGravity.CENTER,
    //     toastLength: Toast.LENGTH_LONG);
    if (_userName == null || _userName!.isEmpty) {
      return;
    }
    if (_password == null || _password!.isEmpty) {
      return;
    }

    ///通过 redux 去执行登陆流程
    StoreProvider.of<GSYState>(context)
        .dispatch(LoginAction(context, _userName, _password));
    return;
  }

  // web授权登录流程
  oauthLogin() async {
    String? code = await NavigatorUtils.goLoginWebView(context,
        Address.getOAuthUrl(), "${GSYLocalizations.i18n(context)!.oauth_text}");

    if (code != null && code.length > 0) {
      ///通过 redux 去执行登陆流程
      StoreProvider.of<GSYState>(context).dispatch(OAuthAction(context, code));
    }
  }

}
