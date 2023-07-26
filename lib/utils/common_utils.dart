import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:car_flutter_demo/localization/default_localizations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

import '../config/config.dart';
import '../local/local_storage.dart';
import '../page/issue_edit_dIalog.dart';
import '../redux/grey_redux.dart';
import '../redux/gsy_state.dart';
import '../redux/locale_redux.dart';
import '../redux/theme_redux.dart';
import '../style/style_const.dart';
import '../widget/gsy_flex_button.dart';
import 'navigator_utils.dart';

typedef StringList = List<String>;

class CommonUtils {
  static const double MILLIS_LIMIT = 1000.0;

  static const double SECONDS_LIMIT = 60 * MILLIS_LIMIT;

  static const double MINUTES_LIMIT = 60 * SECONDS_LIMIT;

  static const double HOURS_LIMIT = 24 * MINUTES_LIMIT;

  static const double DAYS_LIMIT = 30 * HOURS_LIMIT;

  static Locale? curLocale;

  static String getDateStr(DateTime? date) {
    if (date == null || date.toString() == "") {
      return "";
    } else if (date.toString().length < 10) {
      return date.toString();
    }
    return date.toString().substring(0, 10);
  }

  static copy(String? data, BuildContext context) {
    if (data != null) {
      Clipboard.setData(ClipboardData(text: data));
      Fluttertoast.showToast(
          msg: GSYLocalizations.i18n(context)!.option_share_copy_success);
    }
  }

  /// 切换灰色
  static changeGrey(Store<GSYState> store) {
    bool grey = store.state.grey;
    if (Config.DEBUG!) {
      print(store.state.grey);
    }
    store.dispatch(RefreshGreyAction(!grey));
  }

  ///日期格式转换
  static String getNewsTimeStr(DateTime date) {
    int subTimes =
        DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
    return switch (subTimes) {
      < MILLIS_LIMIT => (curLocale != null)
          ? (curLocale!.languageCode != "zh")
              ? "right now"
              : "刚刚"
          : "刚刚",
      < SECONDS_LIMIT => (subTimes / MILLIS_LIMIT).round().toString() +
          ((curLocale != null)
              ? (curLocale!.languageCode != "zh")
                  ? " seconds ago"
                  : " 秒前"
              : " 秒前"),
      < MINUTES_LIMIT => (subTimes / SECONDS_LIMIT).round().toString() +
          ((curLocale != null)
              ? (curLocale!.languageCode != "zh")
                  ? " min ago"
                  : " 分钟前"
              : " 分钟前"),
      < HOURS_LIMIT => (subTimes / MINUTES_LIMIT).round().toString() +
          ((curLocale != null)
              ? (curLocale!.languageCode != "zh")
                  ? " hours ago"
                  : " 小时前"
              : " 小时前"),
      < DAYS_LIMIT => (subTimes / HOURS_LIMIT).round().toString() +
          ((curLocale != null)
              ? (curLocale!.languageCode != "zh")
                  ? " days ago"
                  : " 天前"
              : " 天前"),
      _ => getDateStr(date)
    };
  }

  static launchOutURL(String? url, BuildContext context) async {
    // if (url != null && await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   Fluttertoast.showToast(
    //       msg: GSYLocalizations.i18n(context)!.option_web_launcher_error +
    //           ": " +
    //           (url ?? ""));
    // }
  }

  static getLocalPath() async {
    Directory? appDir;
    if (Platform.isIOS) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getExternalStorageDirectory();
    }

    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (statuses[Permission.storage] != PermissionStatus.granted) {
        return null;
      }
    }
    String appDocPath = appDir!.path + "/myflutter";
    Directory appPath = Directory(appDocPath);
    await appPath.create(recursive: true);
    return appPath;
  }


  static Future<Null> showEditDialog(
      BuildContext context,
      String dialogTitle,
      ValueChanged<String>? onTitleChanged,
      ValueChanged<String> onContentChanged,
      VoidCallback onPressed, {
        TextEditingController? titleController,
        TextEditingController? valueController,
        bool needTitle = true,
      }) {
    return NavigatorUtils.showDefaultDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: IssueEditDialog(
              dialogTitle,
              onTitleChanged,
              onContentChanged,
              onPressed,
              titleController: titleController,
              valueController: valueController,
              needTitle: needTitle,
            ),
          );
        });
  }


  ///列表item dialog
  static Future<Null> showCommitOptionDialog(
      BuildContext context,
      List<String?>? commitMaps,
      ValueChanged<int> onTap, {
        width = 250.0,
        height = 400.0,
        List<Color>? colorList,
      }) {
    return NavigatorUtils.showDefaultDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(4.0),
              margin: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: GSYColors.white,
                //用一个BoxDecoration装饰器提供背景图片
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: ListView.builder(
                  itemCount: commitMaps?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GSYFlexButton(
                      maxLines: 1,
                      mainAxisAlignment: MainAxisAlignment.start,
                      fontSize: 14.0,
                      color: colorList != null
                          ? colorList[index]
                          : Theme.of(context).primaryColor,
                      text: commitMaps![index],
                      textColor: GSYColors.white,
                      onPress: () {
                        Navigator.pop(context);
                        onTap(index);
                      },
                    );
                  }),
            ),
          );
        });
  }

  static getApplicationDocumentsPath() async {
    Directory appDir;
    if (Platform.isIOS) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getApplicationSupportDirectory();
    }
    String appDocPath = appDir.path + "/gsygithubappflutter";
    Directory appPath = Directory(appDocPath);
    await appPath.create(recursive: true);
    return appPath.path;
  }

  static String? removeTextTag(String? description) {
    if (description != null) {
      String reg = "<g-emoji.*?>.+?</g-emoji>";
      RegExp tag = RegExp(reg);
      Iterable<Match> tags = tag.allMatches(description);
      for (Match m in tags) {
        String match = m
            .group(0)!
            .replaceAll(RegExp("<g-emoji.*?>"), "")
            .replaceAll(RegExp("</g-emoji>"), "");
        description = description!.replaceAll(RegExp(m.group(0)!), match);
      }
    }
    return description;
  }

  /*static saveImage(String url) async {
    Future<String> _findPath(String imageUrl) async {
      final file = await Cache.DefaultCacheManager().getSingleFile(url);
      if (file == null) {
        return null;
      }
      Directory localPath = await CommonUtils.getLocalPath();
      if (localPath == null) {
        return null;
      }
      final name = splitFileNameByPath(file.path);
      final result = await file.copy(localPath.path + name);
      return result.path;
    }

    return _findPath(url);
  }*/

  static splitFileNameByPath(String path) {
    return path.substring(path.lastIndexOf("/"));
  }

  static getFullName(String? repository_url) {
    if (repository_url != null &&
        repository_url.substring(repository_url.length - 1) == "/") {
      repository_url = repository_url.substring(0, repository_url.length - 1);
    }
    String fullName = '';
    if (repository_url != null) {
      StringList splicurl = repository_url.split("/");
      if (splicurl.length > 2) {
        fullName =
            splicurl[splicurl.length - 2] + "/" + splicurl[splicurl.length - 1];
      }
    }
    return fullName;
  }

  static pushTheme(Store store, int index) {
    ThemeData themeData;
    List<Color> colors = getThemeListColor();
    themeData = getThemeData(colors[index]);
    store.dispatch(RefreshThemeDataAction(themeData));
  }

  static getThemeData(Color color) {
    return ThemeData(
      primarySwatch: color as MaterialColor?,
      platform: TargetPlatform.android,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarContrastEnforced: true,
          systemStatusBarContrastEnforced: true,
          systemNavigationBarColor: color,
          statusBarColor: color,
          systemNavigationBarDividerColor: color.withAlpha(199),
        ),
      ),
      // 如果需要去除对应的水波纹效果
      // splashFactory: NoSplash.splashFactory,
      // textButtonTheme: TextButtonThemeData(
      //   style: ButtonStyle(splashFactory: NoSplash.splashFactory),
      // ),
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //   style: ButtonStyle(splashFactory: NoSplash.splashFactory),
      // ),
    );
  }

  /// 切换语言的对话框
  static showLanguageDialog(BuildContext context) {
    StringList list = [
      GSYLocalizations.i18n(context)!.home_language_default,
      GSYLocalizations.i18n(context)!.home_language_zh,
      GSYLocalizations.i18n(context)!.home_language_en,
    ];
    CommonUtils.showCommitOptionDialog(context, list, (index) {
      CommonUtils.changeLocale(StoreProvider.of<GSYState>(context), index);
      LocalStorage.save(Config.LOCALE, index.toString());
    }, height: 150.0);
  }

  ///获取设备信息
  static Future<String> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return "";
    }
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.model ?? "";
  }

  /**
   * 切换语言
   */
  static changeLocale(Store<GSYState> store, int index) {
    Locale? locale = store.state.platformLocale;
    if (Config.DEBUG!) {
      print(store.state.platformLocale);
    }
    switch (index) {
      case 1:
        locale = Locale('zh', 'CH');
        break;
      case 2:
        locale = Locale('en', 'US');
        break;
    }
    curLocale = locale;
    store.dispatch(RefreshLocaleAction(locale));
  }


  static List<Color> getThemeListColor() {
    return [
      Colors.brown,
      Colors.blue,
      Colors.teal,
      Colors.amber,
      Colors.blueGrey,
      Colors.deepOrange,
    ];
  }

  static const IMAGE_END = [".png", ".jpg", ".jpeg", ".gif", ".svg"];

  static isImageEnd(path) {
    bool image = false;
    for (String item in IMAGE_END) {
      if (path.indexOf(item) + item.length == path.length) {
        image = true;
      }
    }
    return image;
  }

  static Future<Null> showLoadingDialog(BuildContext context) {
    return NavigatorUtils.showDefaultDialog(
        context: context,
        builder: (BuildContext context) {
          return Material(
              color: Colors.transparent,
              child: WillPopScope(
                onWillPop: () => Future.value(false),
                child: Center(
                  child: Container(
                    width: 200.0,
                    height: 200.0,
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      //用一个BoxDecoration装饰器提供背景图片
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // new Container(
                        //     child: SpinKitCubeGrid(color: GSYColors.white)),
                        Container(height: 10.0),
                        // new Container(
                        //     child: new Text(
                        //         Localizations.i18n(context)!.loading_text,
                        //         style: Constant.normalTextWhite)),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }
}
