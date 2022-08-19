import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:flutter/material.dart';

class AppThemeAndLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en');

  Locale get appLocale => _appLocale ?? Locale("en");

  fetchLocale() async {
    String languageCode = await SharedPrefUtil.getString(kKeyLanguage);

    if (languageCode.isEmpty) {
      _appLocale = Locale('en');
      await SharedPrefUtil.writeString(
        kKeyLanguage,
        _appLocale.languageCode.toLowerCase(),
      );
      return Null;
    }

    _appLocale = Locale(languageCode);
    return Null;
  }

  Future<bool> changeLanguage(Locale type) async {
    if (_appLocale == type) {
      return true;
    }

    _appLocale = type;
    bool isLanguageChanged = await SharedPrefUtil.writeString(
      kKeyLanguage,
      _appLocale.languageCode.toLowerCase(),
    );

    notifyListeners();
    return isLanguageChanged;
  }

  ThemeData _themeData;

  ThemeData get themeData => _themeData ?? ThemeData(
    backgroundColor: kCommonBackgroundColor,
    primaryColor: kPrimaryColor,
    accentColor: kAccentColor,
    fontFamily: 'Roboto',
  );

  void setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  int _cartItemCount;

  int get cartItemCount => _cartItemCount ?? kDefaultInt;

  void setCartItemCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }
}
