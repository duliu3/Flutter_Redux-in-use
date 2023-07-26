import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../dao/user_dao.dart';
import '../redux/gsy_state.dart';
import '../style/style_const.dart';
import '../utils/navigator_utils.dart';

class WelcomePage extends StatefulWidget {
  static final String sName = "/";

  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool hadInit = false;

  String text = "";
  double fontSize = 76;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hadInit) {
      return;
    }
    hadInit = true;

    ///防止多次进入
    Store<GSYState> store = StoreProvider.of(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        text = "Welcome";
        fontSize = 60;
      });
    });
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      setState(() {
        text = "Flutter APP";
        fontSize = 60;
      });
    });
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      UserDao.initUserInfo(store).then((res) {
        if (res != null && res.result) {
          NavigatorUtils.goHome(context);
        } else {
          NavigatorUtils.goLogin(context);
        }
        return true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<GSYState>(
      builder: (context, store) {
        double size = 200;
        return Material(
          child: Center(
          child: Text(
          text,
          style: TextStyle(fontSize: 16.0),
          ),
        )
          //   Container(
          //   color: GSYColors.white,
          //   child: Stack(
          //     children: <Widget>[
          //       // Center(
          //       //   child: Image(
          //       //       image: AssetImage('static/images/welcome.png')),
          //       // ),
          //       Align(
          //         alignment: Alignment(0.0, 0.3),
          //         child: Text(
          //          text
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        );
      },
    );
  }
}
