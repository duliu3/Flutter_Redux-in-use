import 'dart:async';

import 'package:car_flutter_demo/page/error_page.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'env/config_wrapper.dart';
import 'env/dev.dart';
import 'env/env_config.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

void main() {
  runZonedGuarded(() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
      ///可以参考 _defaultErrorWidgetBuilder 通过自定义 RenderErrorBox 实现
      return ErrorPage(
          details.exception.toString() + "\n " + details.stack.toString(), details);
    };
    runApp(ConfigWrapper(
      child: FlutterReduxApp(),
      config: EnvConfig.fromJson(config),
    ));
    ///屏幕刷新率和显示率不一致时的优化，必须挪动到 runApp 之后
    GestureBinding.instance.resamplingEnabled = true;
    logger.d("init app");
  }, (Object obj, StackTrace stack) {
    print(obj);
    print(stack);
  });
}

