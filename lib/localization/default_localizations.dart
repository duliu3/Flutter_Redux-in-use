import 'package:car_flutter_demo/localization/string_base.dart';
import 'package:car_flutter_demo/localization/string_en.dart';
import 'package:car_flutter_demo/localization/string_zh.dart';
import 'package:flutter/material.dart';

///自定义多语言实现
class GSYLocalizations {
  final Locale locale;

  GSYLocalizations(this.locale);

  ///根据不同 locale.languageCode 加载不同语言对应
  static Map<String, StringBase> _localizedValues = {
    'en': new StringEn(),
    'zh': new StringZh(),
  };

  StringBase? get currentLocalized {
    if (_localizedValues.containsKey(locale.languageCode)) {
      return _localizedValues[locale.languageCode];
    }
    return _localizedValues["en"];
  }

  ///通过 Localizations 加载当前的 GSYLocalizations
  static GSYLocalizations? of(BuildContext context) {
    return Localizations.of(context, GSYLocalizations);
  }

  ///通过 Localizations 加载当前的 GSYLocalizations
  static StringBase? i18n(BuildContext context) {
    return (Localizations.of(context, GSYLocalizations) as GSYLocalizations)
        .currentLocalized;
  }
}
