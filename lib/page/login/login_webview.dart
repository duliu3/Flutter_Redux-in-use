import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../localization/default_localizations.dart';
import '../../style/style_const.dart';
import '../../widget/gsy_common_option_widget.dart';


class LoginWebView extends StatefulWidget {
  final String url;
  final String title;

  LoginWebView(this.url, this.title);

  @override
  _LoginWebViewState createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  _renderTitle() {
    if (widget.url.length == 0) {
      return Text(widget.title);
    }
    return Row(children: [
      Expanded(
          child: Container(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )),
      GSYCommonOptionWidget(url: widget.url),
    ]);
  }

  final FocusNode focusNode = FocusNode();

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _renderTitle(),
      ),
      body: Stack(
        children: <Widget>[
          TextField(
            focusNode: focusNode,
          ),
          WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              navigationDelegate: (NavigationRequest navigation) {
                if (navigation.url.startsWith("gsygithubapp://authed")) {
                  var code = Uri.parse(navigation.url).queryParameters["code"];
                  print("code ${code}");
                  Navigator.of(context).pop(code);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onPageFinished: (_) {
                setState(() {
                  isLoading = false;
                });
              }),
          if (isLoading)
            Center(
              child: Container(
                width: 200.0,
                height: 200.0,
                padding: EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitDoubleBounce(
                        color: Theme.of(context).primaryColor),
                    Container(width: 10.0),
                    Container(
                        child: Text(
                            GSYLocalizations.i18n(context)!.loading_text,
                            style: GSYConstant.middleText)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}