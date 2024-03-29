import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../main.dart';
import 'gsy_pull_load_widget.dart';

/**
 * 上下拉刷新列表的通用State
 */
mixin GSYListState<T extends StatefulWidget>
    on State<T>, AutomaticKeepAliveClientMixin<T> {
  bool isShow = false;

  bool isLoading = false;

  int page = 1;

  bool isRefreshing = false;

  bool isLoadMoring = false;

  final List dataList = [];

  final GSYPullLoadWidgetControl pullLoadWidgetControl =
      GSYPullLoadWidgetControl();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _lockToAwait() async {
    ///if loading, lock to await
    doDelayed() async {
      await Future.delayed(Duration(seconds: 1)).then((_) async {
        if (isLoading) {
          return await doDelayed();
        } else {
          return null;
        }
      });
    }

    await doDelayed();
  }

  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshIndicatorKey.currentState!.show().then((e) {});
      return true;
    });
  }

  @protected
  resolveRefreshResult(res) {
    if (res != null && res.result) {
      pullLoadWidgetControl.dataList.clear();
      logger.d("list result refresh");
      if (isShow) {
        setState(() {
          pullLoadWidgetControl.dataList.addAll(res.data);
        });
      }
    }
  }

  @protected
  Future<Null> handleRefresh() async {
    if (isLoading) {
      if (isRefreshing) {
        return null;
      }
      await _lockToAwait();
    }
    isLoading = true;
    isRefreshing = true;
    page = 1;
    var res = await requestRefresh();
    logger.d("list handleRefresh ${res}");
    resolveRefreshResult(res);
    resolveDataResult(res);
    if (res.next != null) {
      var resNext = await res.next();
      resolveRefreshResult(resNext);
      resolveDataResult(resNext);
    }
    isLoading = false;
    isRefreshing = false;
    return null;
  }

  @protected
  Future<Null> onLoadMore() async {
    if (isLoading) {
      if (isLoadMoring) {
        return null;
      }
      await _lockToAwait();
    }
    isLoading = true;
    isLoadMoring = true;
    page++;
    var res = await requestLoadMore();
    if (res != null && res.result) {
      if (isShow) {
        setState(() {
          pullLoadWidgetControl.dataList.addAll(res.data);
        });
      }
    }
    resolveDataResult(res);
    isLoading = false;
    isLoadMoring = false;
    return null;
  }

  @protected
  resolveDataResult(res) {
    if (isShow) {
      setState(() {
        pullLoadWidgetControl.needLoadMore.value = (res != null &&
            res.data != null &&
            res.data.length >= Config.PAGE_SIZE);
      });
    }
  }

  @protected
  clearData() {
    if (isShow) {
      setState(() {
        pullLoadWidgetControl.dataList.clear();
      });
    }
  }

  ///下拉刷新数据
  @protected
  requestRefresh() async {}

  ///上拉更多请求数据
  @protected
  requestLoadMore() async {}

  ///是否需要第一次进入自动刷新
  @protected
  bool get isRefreshFirst;

  ///是否需要头部
  @protected
  bool get needHeader => false;

  ///是否需要保持
  @override
  bool get wantKeepAlive => true;

  List get getDataList => dataList;

  @override
  void initState() {
    isShow = true;
    super.initState();
    pullLoadWidgetControl.needHeader = needHeader;
    pullLoadWidgetControl.dataList = getDataList;
    if (pullLoadWidgetControl.dataList.length == 0 && isRefreshFirst) {
      showRefreshLoading();
    }
  }

  @override
  void dispose() {
    isShow = false;
    isLoading = false;
    super.dispose();
  }
}
