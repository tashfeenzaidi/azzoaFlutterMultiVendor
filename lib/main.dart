import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/auth/splash/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:google_map_location_picker/generated/l10n.dart'
//     as LocationPicker;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  AppThemeAndLanguage themeAndLang = AppThemeAndLanguage();
  await themeAndLang.fetchLocale();

  runApp(
    MyApp(themeAndLang: themeAndLang),
  );
}

class MyApp extends StatelessWidget {
  final AppThemeAndLanguage themeAndLang;
  final AppConfigNotifier _appConfigNotifier = AppConfigNotifier();

  MyApp({@required this.themeAndLang});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeAndLanguage>.value(value: themeAndLang),
        ChangeNotifierProvider<AppConfigNotifier>.value(
          value: _appConfigNotifier,
        ),
      ],
      child: Consumer<AppThemeAndLanguage>(builder: (context, model, child) {
        return MaterialApp(
          locale: themeAndLang.appLocale,
          supportedLocales: [
            Locale('en'),
            Locale('bn'),
          ],
          // localizationsDelegates: [
          //   LocationPicker.S.delegate,
          //   AppLocalizations.delegate,
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          // ],
          theme: themeAndLang.themeData,
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
      }),
    );
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  // Do nothing for now as FCM itself stores a notification in the tray
}
