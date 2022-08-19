import 'dart:async';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/local/service/database_service.dart';
import 'package:azzoa_grocery/data/remote/model/app_info.dart';
import 'package:azzoa_grocery/data/remote/response/config_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/auth/login/login.dart';
import 'package:azzoa_grocery/ui/auth/preference/preference.dart';
import 'package:azzoa_grocery/ui/container/home/homepage.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading, hasError;
  String error;
  String appLogo, appName;
  AppConfig appConfig;
  AppConfigNotifier appConfigNotifier;
  AppThemeAndLanguage themeAndLanguage;

  void goToNextPage() async {
    bool isLoggedIn = await SharedPrefUtil.getBoolean(kKeyIsLoggedIn);
    appConfigNotifier.setAppConfig(this.appConfig);
    themeAndLanguage.setThemeData(
      ThemeData(
        backgroundColor: kCommonBackgroundColor,
        primaryColor: ColorUtil.hexToColor(
          appConfigNotifier.appConfig.color.colorPrimary,
        ),
        accentColor: ColorUtil.hexToColor(
          appConfigNotifier.appConfig.color.colorAccent,
        ),
        buttonColor: ColorUtil.hexToColor(
          appConfigNotifier.appConfig.color.colorAccent,
        ),
        fontFamily: 'Roboto',
      ),
    );

    if (this.context != null) {
      if (!(await SharedPrefUtil.contains(kKeyCurrency)) ||
          (await SharedPrefUtil.getString(kKeyCurrency)).isEmpty ||
          !(await SharedPrefUtil.contains(kKeyLanguage)) ||
          (await SharedPrefUtil.getString(kKeyLanguage)).isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetPreferencePage(),
          ),
        );
      } else {
        if (!isLoggedIn) {
          String currencyCode = await SharedPrefUtil.getString(kKeyCurrency);
          String language = await SharedPrefUtil.getString(kKeyLanguage);

          await SharedPrefUtil.clear().then((value) async {
            await DatabaseService.on().clearDatabase();

            await SharedPrefUtil.writeString(
              kKeyCurrency,
              currencyCode,
            );

            await SharedPrefUtil.writeString(
              kKeyLanguage,
              language,
            );
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isLoggedIn ? HomePage() : LoginPage(),
          ),
        );
      }
    }
  }

  Future _checkAndGetLocation() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        ToastUtil.show(getString('enable_your_gps'));
      }
    } else {
      Position lastKnownPosition = await Geolocator.getLastKnownPosition();

      if (lastKnownPosition != null) {
        appConfigNotifier.setCurrentLocation(lastKnownPosition);
      } else {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then(
          (Position position) {
            appConfigNotifier.setCurrentLocation(position);
          },
        ).catchError(
          (e) {
            ToastUtil.show(getString('fetch_location_error'));
          },
        );
      }
    }
  }

  @override
  void initState() {
    isLoading = false;
    hasError = false;
    error = kDefaultString;
    appLogo = kDefaultString;
    appName = kDefaultString;

    super.initState();
  }

  Future<void> _getAppConfig({bool loadNeeded = false}) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      ConfigResponse response = await NetworkHelper.on().getAppConfig(context);

      if (response != null) {
        this.appConfig = response.appConfig;

        if (this.mounted) {
          setState(() {
            appLogo = appConfig.logo;
            appName = appConfig.name;
            hasError = false;

            if (loadNeeded) {
              isLoading = false;
            }
          });
        }

        Timer(
          Duration(seconds: 3),
          goToNextPage,
        );
      } else {
        if (this.mounted) {
          setState(() {
            hasError = true;

            if (loadNeeded) {
              isLoading = false;
            }
          });
        }

        error = getString('could_not_load_app_config');
      }
    } catch (e) {
      setState(() {
        hasError = true;

        if (loadNeeded) {
          isLoading = false;
        }
      });

      if (!(e is AppException)) {
        error = getString('could_not_load_app_config');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    themeAndLanguage = Provider.of<AppThemeAndLanguage>(
      context,
      listen: false,
    );
    _checkAndGetLocation();
    _getAppConfig();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('images/ic_splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : (hasError
                ? buildErrorBody(error)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        appLogo,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 32.0,
                        ),
                        child: Text(
                          appName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }

  Widget buildErrorBody(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: kRegularTextColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}
