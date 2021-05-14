//This is the web view page

import 'dart:async';
import 'package:ash_bus/models/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ash_bus/models/constants.dart' as Constants;

class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({Key key, this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }

  //Check the payment status
  checkSuccess()  {
    setState(() {
      Hive.box(Constants.MAINBOX).put(Constants.VIRTUAL_WALLET, Hive.box(Constants.MAINBOX).get(Constants.VIRTUAL_WALLET) + int.parse(Constants.walletAmountToPay));
      var months = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November","December"];
      Constants.transaction.add({"amount": walletAmountToPay, "date": "${DateTime.now().day} ${months[DateTime.now().month]} ${DateTime.now().year}", "time": "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}"});
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(width * 0.05),
          child: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context),
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.ashesi.edu.gh/')) {
                print('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
            },
            gestureNavigationEnabled: true,
          ),
        ),

        floatingActionButton: FlatButton(
          onPressed: (){
            checkSuccess();
            Navigator.pop(context);
          },
          color: wineBackgroundColor,
          padding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(side: BorderSide(
              color: wineBackgroundColor,
              width: 1,
              style: BorderStyle.solid
          ), borderRadius: BorderRadius.circular(50)),
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.subdirectory_arrow_left, color: Colors.white),
                SizedBox(width: 5,),
                Text("Back to App",
                  style: TextStyle(color: Colors.white),)
              ],
            ),
          ),
        ),
      ),
    );

  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}