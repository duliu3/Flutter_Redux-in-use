import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';

import '../db/provider/user_repos_db_provider.dart';
import '../model/Repository.dart';
import '../network/address.dart';
import '../network/api.dart';
import 'dao_result.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-16
 */

class ReposDao {

  /**
   * 用户的仓库
   */
  static getUserRepositoryDao(userName, page, sort, {needDb = false}) async {
    UserReposDbProvider provider = new UserReposDbProvider();
    next() async {
      String url = Address.userRepos(userName, sort) + Address.getPageParams("&", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = [];
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return new DataResult(null, false);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(userName, json.encode(dataList));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository>? list = await provider.geData(userName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }
}
