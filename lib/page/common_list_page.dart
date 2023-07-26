import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../dao/dao_result.dart';
import '../dao/repos_dao.dart';
import '../main.dart';
import '../model/CommonListDataType.dart';
import '../model/License.dart';
import '../model/Repository.dart';
import '../model/RepositoryPermissions.dart';
import '../repos/repos_item.dart';
import '../utils/navigator_utils.dart';
import '../widget/pull/gsy_list_state.dart';
import '../widget/pull/gsy_pull_load_widget.dart';

class CommonListPage extends StatefulWidget {
  // final String? userName;
  //
  // final String? reposName;
  //
  // final String showType;
  //
  // final String? title;

  CommonListPage({super.key});

  @override
  CommonListPageState createState() => CommonListPageState();
}

class CommonListPageState extends State<CommonListPage>
    with
        AutomaticKeepAliveClientMixin<CommonListPage>,
        GSYListState<CommonListPage> {
  CommonListPageState();

  _renderItem(index) {
    logger.d("_renderItem item ${pullLoadWidgetControl.dataList.length}");
    if (pullLoadWidgetControl.dataList.length == 0) {
      return null;
    }
    var data = pullLoadWidgetControl.dataList[index];
        ReposViewModel reposViewModel = ReposViewModel.fromMap(data);
        return ReposItem(reposViewModel, onPressed: () {
          // NavigatorUtils.goReposDetail(
          //     context, reposViewModel.ownerName, reposViewModel.repositoryName);
        });
  }

  _getDataLogic() async {
    logger.d("list _getDataLogic ");
    // todo 模拟网络请求返回结果
      // await ReposDao.getUserRepositoryDao(
      //     "duliu3", page, null,
      //     needDb: page <= 1);
    List<Repository> list = [];
    Map<String, dynamic> json = {
      "id": 123,
      "size": 456,
      "name": "example",
      "full_name": "example/fullName",
      "html_url": "https://example.com",
      "description": "example description",
      "language": "Java",
      "default_branch": "master",
      "created_at": "2023-07-04T10:00:00.000Z",
      "updated_at": "2023-07-04T11:00:00.000Z",
      "pushed_at": "2023-07-04T12:00:00.000Z",
      "git_url": "git://example.com",
      "ssh_url": "ssh://example.com",
      "clone_url": "https://example.com/clone",
      "svn_url": "svn://example.com",
      "stargazers_count": 789,
      "watchers_count": 1011,
      "forks_count": 1213,
      "open_issues_count": 1415,
      "subscribers_count": 1617,
      "private": true,
      "fork": false,
      "has_issues": true,
      "has_projects": false,
      "has_downloads": true,
      "has_wiki": false,
      "has_pages": true,
      "owner": {
        "id": 234,
        "login": "exampleUser",
        "avatar_url": "https://example.com/avatar",
        "html_url": "https://example.com/user"
      },
      "license": {
        "key": "MIT",
        "name": "MIT License",
        "spdx_id": "MIT License",
        "url": "https://example.com/license"
      },
    };
    // var repository = Repository.fromJson(json);
    // list.add(repository);
    var list2 = List.generate(10, (index) => Repository.fromJson(json));
    return DataResult(list2, true);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {
    logger.d("list refresh ");
    return await _getDataLogic();
  }

  @override
  requestLoadMore() async {
    logger.d("list loadmore");
    return await _getDataLogic();
  }

  @override
  bool get isRefreshFirst => true;

  @override
  bool get needHeader => false;

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    return GSYPullLoadWidget(
        pullLoadWidgetControl,
        (BuildContext context, int index) => _renderItem(index),
        handleRefresh,
        onLoadMore,
        refreshKey: refreshIndicatorKey,
    );
  }
}
