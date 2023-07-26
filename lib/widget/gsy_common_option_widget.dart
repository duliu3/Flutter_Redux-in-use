import 'package:car_flutter_demo/utils/logger.dart';
import 'package:flutter/material.dart';

import '../localization/default_localizations.dart';
import '../style/style_const.dart';
import '../utils/common_utils.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-26
 */
class GSYCommonOptionWidget extends StatelessWidget {
  final List<GSYOptionModel>? otherList;

  final String? url;

  GSYCommonOptionWidget({this.otherList, String? url})
      : this.url = (url == null) ? GSYConstant.app_default_share_url : url;

  _renderHeaderPopItem(List<GSYOptionModel> list) {
    return PopupMenuButton<GSYOptionModel>(
      child: Icon(GSYICons.MORE),
      onSelected: (model) {
        model.selected(model);
      },
      itemBuilder: (BuildContext context) {
        return _renderHeaderPopItemChild(list);
      },
    );
  }

  _renderHeaderPopItemChild(List<GSYOptionModel> data) {
    List<PopupMenuEntry<GSYOptionModel>> list = [];
    for (GSYOptionModel item in data) {
      list.add(PopupMenuItem<GSYOptionModel>(
        value: item,
        child: Text(item.name),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    List<GSYOptionModel> constList = [
      // GSYOptionModel(GSYLocalizations.i18n(context)!.option_web,
      //     GSYLocalizations.i18n(context)!.option_web, (model) {
      //   CommonUtils.launchOutURL(url, context);
      // }),
      GSYOptionModel(GSYLocalizations.i18n(context)!.option_copy,
          GSYLocalizations.i18n(context)!.option_copy, (model) {
        CommonUtils.copy(url ?? "", context);
      }),
      // GSYOptionModel(GSYLocalizations.i18n(context)!.option_share,
      //     GSYLocalizations.i18n(context)!.option_share, (model) {
      //   Share.share(
      //       GSYLocalizations.i18n(context)!.option_share_title + (url ?? ""));
      // }),
    ];
    var list = [...constList, ...?otherList];
    return _renderHeaderPopItem(list);
  }
}

class GSYOptionModel {
  final String name;
  final String value;
  final PopupMenuItemSelected<GSYOptionModel> selected;

  GSYOptionModel(this.name, this.value, this.selected);
}
