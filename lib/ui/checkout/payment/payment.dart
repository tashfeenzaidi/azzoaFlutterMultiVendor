import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({@required this.url});

  final String url;

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  WebViewController _controller;
  num _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String _successfulPaymentUrlPrefix = kBaseUrl + "payment-success/";
    const String _failedPaymentUrlPrefix = kBaseUrl + "payment-failed/";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: kCommonBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('payment_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _stackToView,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: WebView(
                      navigationDelegate: (action) {
                        if (action.url
                                .startsWith(_successfulPaymentUrlPrefix) ||
                            action.url.startsWith(_failedPaymentUrlPrefix)) {
                          Navigator.pop(
                            context,
                            action.url.startsWith(_successfulPaymentUrlPrefix),
                          );
                        }

                        return NavigationDecision.navigate;
                      },
                      debuggingEnabled: true,
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageFinished: _handleLoad,
                      onWebViewCreated: (WebViewController controller) {
                        _controller = controller;
                      },
                    ),
                  ),
                ],
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}
