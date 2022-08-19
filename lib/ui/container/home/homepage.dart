import 'dart:io';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/cart/cart.dart';
import 'package:azzoa_grocery/ui/container/home/homepage_content.dart';
import 'package:azzoa_grocery/ui/container/profile/menu/profile_menu.dart';
import 'package:azzoa_grocery/ui/container/search/global_search.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedBottomBarIndex;
  Widget body;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  AppConfigNotifier appConfigNotifier;
  AppThemeAndLanguage themeAndLanguageNotifier;
  bool hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false);
    themeAndLanguageNotifier = Provider.of<AppThemeAndLanguage>(context);
    if (!hasFetched) _getCartItemCount();
  }

  @override
  void initState() {
    selectedBottomBarIndex = 0;
    body = HomeContentPage();

    NotificationUtil.on().configLocalNotification(selectNotification);

    Future.delayed(
      Duration(seconds: 1),
      () {
        _firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            NotificationUtil.on().showNotification(message);
          },
          onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
          onLaunch: (Map<String, dynamic> message) async {
            // Do nothing for now as we are not tapping on the notification
          },
          onResume: (Map<String, dynamic> message) async {
            // Do nothing for now as we are not tapping on the notification
          },
        );
      },
    );

    _firebaseMessaging.onTokenRefresh.listen(
      (token) {
        if (token != null && token.trim().isNotEmpty) {
          _updateDeviceTokenAtServer(token);
        }
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: true,
      ),
    );

    _firebaseMessaging.onIosSettingsRegistered.listen(
      (IosNotificationSettings settings) {
        // Do nothing for now
      },
    );

    super.initState();
  }

  Future<void> _updateDeviceTokenAtServer(String deviceToken) async {
    try {
      BaseResponse response = await NetworkHelper.on().updateDeviceToken(
        context,
        deviceToken,
      );

      if (response != null && response.status != null && response.status == 200) {
        // Do nothing for now
        /*if (response.message != null && response.message.trim().isNotEmpty) {
          ToastUtil.show(response.message.trim());
        }*/
      }
    } catch (e) {
      if (!(e is AppException)) {
        // Do nothing for now
      }
    }
  }

  void _getCartItemCount() async {
    hasFetched = true;
    CartResponse response = await NetworkHelper.on().getCart(context);

    if (response != null &&
        response.status != null &&
        response.status == 200 &&
        response.data != null &&
        response.data.jsonObject != null &&
        response.data.jsonObject.items.isNotEmpty) {
      themeAndLanguageNotifier.setCartItemCount(response.data.jsonObject.items.length);
    }
  }

  Future selectNotification(String payload) async {
    if (payload != null && payload.isNotEmpty) {
      print('notification payload: ' + payload);
    }
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
        extendBodyBehindAppBar: true,
        backgroundColor: kCommonBackgroundColor,
        body: body,
        bottomNavigationBar: buildBottomBar(),
      ),
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  BottomNavigationBar buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: selectedBottomBarIndex,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      items: [
        getBottomBarItem(
          'images/ic_home.png',
          getString('homepage_home'),
          0,
        ),
        getBottomBarItem(
          'images/ic_search.png',
          getString('homepage_search'),
          1,
        ),
        getBottomBarItem(
          'images/ic_order.png',
          getString('homepage_cart'),
          2,
          badgeCount: themeAndLanguageNotifier.cartItemCount,
        ),
        getBottomBarItem(
          'images/ic_account.png',
          getString('homepage_account'),
          3,
        ),
      ],
      onTap: _onBottomBarItemTapped,
    );
  }

  void _onBottomBarItemTapped(int index) {
    if (this.mounted) {
      setState(() {
        switch (index) {
          case 0:
            selectedBottomBarIndex = index;
            body = HomeContentPage();
            break;

          case 1:
            selectedBottomBarIndex = index;
            body = GlobalSearchPage();
            break;

          case 2:
            selectedBottomBarIndex = index;
            body = CartPage(root: this);
            break;

          case 3:
            selectedBottomBarIndex = index;
            body = ProfileMenuPage();
            break;

          default:
            break;
        }
      });
    }
  }

  BottomNavigationBarItem getBottomBarItem(
    String imagePath,
    String title,
    int position, {
    int badgeCount,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imagePath,
                color: selectedBottomBarIndex == position
                    ? ColorUtil.hexToColor(
                        appConfigNotifier.appConfig.color.colorAccent,
                      )
                    : Color(0xFFC0CFD0),
                fit: BoxFit.fitHeight,
                height: 20.0,
              ),
            ),
            if (badgeCount != null && badgeCount != kDefaultInt)
              Positioned(
                top: 4,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedBottomBarIndex == position
                        ? ColorUtil.hexToColor(
                            appConfigNotifier.appConfig.color.colorAccent,
                          )
                        : /*Color(0xFFC0CFD0)*/ Colors.red.withOpacity(0.6),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      label: title,
    );
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
// Do nothing for now as FCM itself stores a notification in the tray
}
