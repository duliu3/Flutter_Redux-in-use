import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';

import '../config/config.dart';
import '../local/local_storage.dart';
import '../localization/default_localizations.dart';
import '../model/User.dart';
import '../redux/gsy_state.dart';
import '../redux/login_redux.dart';
import '../style/style_const.dart';
import '../utils/common_utils.dart';
import '../utils/navigator_utils.dart';
import 'gsy_flex_button.dart';

/**
 * 主页drawer
 * Created by guoshuyu
 * Date: 2018-07-18
 */
class HomeDrawer extends StatelessWidget {
  showAboutDialog(BuildContext context, String? versionName) {
    versionName ??= "Null";
    NavigatorUtils.showDefaultDialog(
        context: context,
        builder: (BuildContext context) => AboutDialog(
              applicationName: GSYLocalizations.i18n(context)!.app_name,
              applicationVersion: GSYLocalizations.i18n(context)!.app_version +
                  ": " +
                  (versionName ?? ""),
              applicationIcon: Image(
                  image: AssetImage(GSYICons.DEFAULT_USER_ICON),
                  width: 50.0,
                  height: 50.0),
              applicationLegalese: "",
            ));
  }

  showThemeDialog(BuildContext context, Store store) {
    StringList list = [
      GSYLocalizations.i18n(context)!.home_theme_default,
      GSYLocalizations.i18n(context)!.home_theme_1,
      GSYLocalizations.i18n(context)!.home_theme_2,
      GSYLocalizations.i18n(context)!.home_theme_3,
      GSYLocalizations.i18n(context)!.home_theme_4,
      GSYLocalizations.i18n(context)!.home_theme_5,
      GSYLocalizations.i18n(context)!.home_theme_6,
    ];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.pushTheme(store, index);
      LocalStorage.save(Config.THEME_COLOR, index.toString());
    }, colorList: CommonUtils.getThemeListColor());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StoreBuilder<GSYState>(
        builder: (context, store) {
          User user = store.state.userInfo!;
          return Drawer(
            ///侧边栏按钮Drawer
            child: Container(
              ///默认背景
              color: store.state.themeData!.primaryColor,
              child: SingleChildScrollView(
                ///item 背景
                child: Container(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height),
                  child: Material(
                    color: GSYColors.white,
                    child: Column(
                      children: <Widget>[
                        UserAccountsDrawerHeader(
                          //Material内置控件
                          accountName: Text(
                            user.login ?? "---",
                            style: GSYConstant.largeTextWhite,
                          ),
                          accountEmail: Text(
                            user.email ?? user.name ?? "---",
                            style: GSYConstant.normalTextLight,
                          ),
                          //用户名
                          //用户邮箱
                          currentAccountPicture: GestureDetector(
                            //用户头像
                            onTap: () {},
                            child: CircleAvatar(
                              //圆形图标控件
                              backgroundImage: NetworkImage(
                                  user.avatar_url ??
                                      GSYICons.DEFAULT_USER_ICON),
                            ),
                          ),
                          decoration: BoxDecoration(
                            //用一个BoxDecoration装饰器提供背景图片
                            color: store.state.themeData!.primaryColor,
                          ),
                        ),
                        ListTile(
                            title: Text(
                              GSYLocalizations.i18n(context)!.home_reply,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              String content = "";
                              CommonUtils.showEditDialog(
                                  context,
                                  GSYLocalizations.i18n(context)!.home_reply,
                                  (title) {}, (res) {
                                content = res;
                              }, () {
                                if (content.length == 0) {
                                  return;
                                }
                                // CommonUtils.showLoadingDialog(context);
                                // request(
                                // }).then((result) {
                                //   Navigator.pop(context);
                                //   Navigator.pop(context);
                                // });
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                                  titleController: TextEditingController(),
                                  valueController: TextEditingController(),
                                  needTitle: false);
                            }),
                        ListTile(
                            title: Text(
                              GSYLocalizations.i18n(context)!.home_change_theme,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              showThemeDialog(context, store);
                            }),
                        ListTile(
                            title: Text(
                              GSYLocalizations.i18n(context)!
                                  .home_change_language,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              CommonUtils.showLanguageDialog(context);
                            }),

                        ListTile(
                            title: Text(
                              GSYLocalizations.i18n(context)!
                                  .home_change_grey,
                              style: GSYConstant.normalText,
                            ),
                            onTap: () {
                              CommonUtils.changeGrey(store);
                            }),
                        ListTile(
                            title: Text(
                              GSYLocalizations.of(context)!
                                  .currentLocalized!
                                  .home_about,
                              style: GSYConstant.normalText,
                            ),
                            onLongPress: (){
                              NavigatorUtils.goDebugDataPage(context);
                            },
                            onTap: () {
                              PackageInfo.fromPlatform().then((value) {
                                print(value);
                                showAboutDialog(context, value.version);
                              });
                            }),
                        ListTile(
                            title: GSYFlexButton(
                              text: GSYLocalizations.i18n(context)!.Login_out,
                              color: Colors.redAccent,
                              textColor: GSYColors.textWhite,
                              onPress: () {
                                store.dispatch(LogoutAction(context));
                              },
                            ),
                            onTap: () {}),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
