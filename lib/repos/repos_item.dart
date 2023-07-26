import 'package:flutter/material.dart';

import '../model/Repository.dart';
import '../model/RepositoryQL.dart';
import '../style/style_const.dart';
import '../utils/common_utils.dart';
import '../utils/navigator_utils.dart';
import '../widget/gsy_card_item.dart';
import '../widget/gsy_icon_text.dart';
import '../widget/gsy_user_icon_widget.dart';

/**
 * 仓库Item
 * Created by guoshuyu
 * Date: 2018-07-16
 */
class ReposItem extends StatelessWidget {
  final ReposViewModel reposViewModel;

  final VoidCallback? onPressed;

  ReposItem(this.reposViewModel, {this.onPressed}) : super();

  ///仓库item的底部状态，比如star数量等
  _getBottomItem(BuildContext context, IconData icon, String? text,
      {int flex = 3}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: GSYIConText(
          icon,
          text,
          GSYConstant.smallSubText,
          GSYColors.subTextColor,
          15.0,
          padding: 5.0,
          textWidth: flex == 4
              ? (MediaQuery.sizeOf(context).width - 100) / 3
              : (MediaQuery.sizeOf(context).width - 100) / 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GSYCardItem(
          child: TextButton(
              onPressed: onPressed,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 0.0, top: 10.0, right: 10.0, bottom: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ///头像
                        Image(
                            image: AssetImage(GSYICons.DEFAULT_USER_ICON),
                            width: 50.0,
                            height: 50.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ///仓库名
                              Text(reposViewModel.repositoryName ?? "",
                                  style: GSYConstant.normalTextBold),

                              ///用户名
                              GSYIConText(
                                GSYICons.REPOS_ITEM_USER,
                                reposViewModel.ownerName,
                                GSYConstant.smallSubLightText,
                                GSYColors.subLightTextColor,
                                10.0,
                                padding: 3.0,
                              ),
                            ],
                          ),
                        ),

                        ///仓库语言
                        Text(reposViewModel.repositoryType!,
                            style: GSYConstant.smallSubText),
                      ],
                    ),
                    Container(

                        ///仓库描述
                        child: Text(
                          reposViewModel.repositoryDes!,
                          style: GSYConstant.smallSubText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        margin: EdgeInsets.only(top: 6.0, bottom: 2.0),
                        alignment: Alignment.topLeft),
                    Padding(padding: EdgeInsets.all(10.0)),

                    ///仓库状态数值
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getBottomItem(context, GSYICons.REPOS_ITEM_STAR,
                            reposViewModel.repositoryStar),
                        SizedBox(
                          width: 5,
                        ),
                        _getBottomItem(context, GSYICons.REPOS_ITEM_FORK,
                            reposViewModel.repositoryFork),
                        SizedBox(
                          width: 5,
                        ),
                        _getBottomItem(context, GSYICons.REPOS_ITEM_ISSUE,
                            reposViewModel.repositoryWatch,
                            flex: 4),
                      ],
                    ),
                  ],
                ),
              ))),
    );
  }
}

class ReposViewModel {
  String? ownerName;
  String? ownerPic;
  String? repositoryName;
  String? repositoryStar;
  String? repositoryFork;
  String? repositoryWatch;
  String? hideWatchIcon;
  String? repositoryType = "";
  String? repositoryDes;

  ReposViewModel();

  ReposViewModel.fromMap(Repository data) {
    ownerName = data.owner!.login;
    ownerPic = data.owner!.avatar_url;
    repositoryName = data.name;
    repositoryStar = data.watchersCount.toString();
    repositoryFork = data.forksCount.toString();
    repositoryWatch = data.openIssuesCount.toString();
    repositoryType = data.language ?? '---';
    repositoryDes = data.description ?? '---';
  }

  ReposViewModel.fromQL(RepositoryQL data) {
    ownerName = data.ownerName;
    ownerPic = data.ownerAvatarUrl;
    repositoryName = data.reposName;
    repositoryStar = data.starCount.toString();
    repositoryFork = data.forkCount.toString();
    repositoryWatch = data.watcherCount.toString();
    repositoryType = data.language ?? '---';
    repositoryDes =
        CommonUtils.removeTextTag(data.shortDescriptionHTML) ?? '---';
  }

  ReposViewModel.fromTrendMap(model) {
    ownerName = model.name;
    if (model.contributors.length > 0) {
      ownerPic = model.contributors[0];
    } else {
      ownerPic = "";
    }
    repositoryName = model.reposName;
    repositoryStar = model.starCount;
    repositoryFork = model.forkCount;
    repositoryWatch = model.meta;
    repositoryType = model.language;
    repositoryDes = CommonUtils.removeTextTag(model.description);
  }
}
