
import 'dart:async';
import 'dart:io';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen>{

  final String url = 'http://the-top-fruit.com/index.php?route=common/home';
  WebViewController _controller;
  final Completer<WebViewController> _controllerCompleter = Completer<WebViewController>();

  bool isLoading = true;
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.black,));

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0.0, 0.0),
        child: Container(),
      ),
      body: Stack(
        children: [
           WillPopScope(
            onWillPop: () => _handleBack( context),
            child: WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controllerCompleter.future.then((value) => _controller = value);
                _controllerCompleter.complete(webViewController);
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.contains("mailto:") || request.url.contains("tel:") || request.url.contains("facebook")) {
                  launch(request.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onWebResourceError: (WebResourceError error){
                setState(() {
                  isOnline = false;
                  isLoading = false;
                });
                print("WebView is error (error : $error%)");
              },
              onProgress: (int progress) {
                if(progress == 100){
                  setState(() {
                    isLoading = false;
                  });
                }else{
                  setState(() {
                    isLoading = true;
                  });
                }
                print("WebView is loading (progress : $progress%)");
              },
              onPageStarted: (String url) async {
                _checkInternet();
                print('Page started callback');
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
                print('Page finished loading: $url');
              },
            ),
          ),
          isLoading ? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                  )
              )
          ) : Stack(),
          isOnline ? Stack() : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: RefreshIndicator(
              color: Colors.black,
              onRefresh: () async {
                print('refreshing');
                _controller.reload();
                return Future.delayed(Duration(seconds: 2),() {});
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Text("تاكد من الاتصال بالانترنت تم اسحب لاسفل", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkInternet() async {


    if (await DataConnectionChecker().hasConnection == false) {
      setState(() {
        isOnline = false;
        isLoading = false;
      });
    } else if (await DataConnectionChecker().hasConnection == true) {
      Timer(Duration(microseconds: 1000), () {
        setState(() {
          isOnline = true;
        });
      });
    }
  }

  Future<void> _handleBack(context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'هل تريد اغلاق التطبيق',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('لا', textAlign: TextAlign.left,style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text('نعم', textAlign: TextAlign.right,style: TextStyle(color: Colors.black)),
              ),
            ],
          ));
    }
  }

}