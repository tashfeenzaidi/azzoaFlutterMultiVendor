import 'dart:convert';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/help_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  Future<HelpResponse> _loadHelp;
  AppConfigNotifier appConfigNotifier;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    _loadHelp = NetworkHelper.on().getHelp(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            getString('help'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: kCommonBackgroundColor,
        body: FutureBuilder(
          future: _loadHelp,
          builder: (context, AsyncSnapshot<HelpResponse> snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data.status != null &&
                snapshot.data.status == 200) {
              return buildBody(
                snapshot.data.faqUrl,
                snapshot.data.termAndConditionsUrl,
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget buildBody(
    String faqUrl,
    String termsAndConditionsUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
          ),
          child: Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: false,
              indicatorColor: ColorUtil.hexToColor(
                appConfigNotifier.appConfig.color.colorAccent,
              ),
              labelColor: ColorUtil.hexToColor(
                appConfigNotifier.appConfig.color.colorAccent,
              ),
              unselectedLabelColor: Colors.black,
              controller: _tabController,
              labelStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(
                  text: getString('faq'),
                ),
                Tab(
                  text: getString('terms_and_conditions'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              TabWebView(message: faqUrl),
              TabWebView(message: termsAndConditionsUrl),
            ],
          ),
        ),
      ],
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}

class TabWebView extends StatefulWidget {
  final String message;

  TabWebView({@required this.message});

  @override
  _TabWebViewState createState() => _TabWebViewState();
}

class _TabWebViewState extends State<TabWebView>
    with AutomaticKeepAliveClientMixin<TabWebView> {
  num _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IndexedStack(
      index: _stackToView,
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: WebView(
                debuggingEnabled: false,
                initialUrl: '',
                onPageFinished: _handleLoad,
                onWebViewCreated: (WebViewController controller) {
                  controller.loadUrl(
                    Uri.dataFromString(
                      widget.message,
                      mimeType: 'text/html',
                      encoding: Encoding.getByName('utf-8'),
                    ).toString(),
                  );
                },
              ),
            ),
          ],
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
