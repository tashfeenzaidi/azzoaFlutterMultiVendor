import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/currency.dart';
import 'package:azzoa_grocery/data/remote/model/language.dart';
import 'package:azzoa_grocery/data/remote/response/currency_response.dart';
import 'package:azzoa_grocery/data/remote/response/language_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/auth/login/login.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SetPreferencePage extends StatefulWidget {
  @override
  _SetPreferencePageState createState() => _SetPreferencePageState();
}

class _SetPreferencePageState extends State<SetPreferencePage> {
  Future<LanguageResponse> _futureLanguageList;
  Future<CurrencyResponse> _futureCurrencyList;

  List<Language> _languageList = [];
  List<Currency> _currencyList = [];

  Currency _selectedCurrency;
  Language _selectedLanguage;
  AppThemeAndLanguage _appLanguage;
  AppConfigNotifier appConfigNotifier;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _futureLanguageList = NetworkHelper.on().getLanguageList(context);
    _futureCurrencyList = NetworkHelper.on().getCurrencyList(context);
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _appLanguage = Provider.of<AppThemeAndLanguage>(context);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: kCommonBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            getString('language_and_currency_select_option'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: kCommonBackgroundColor,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 16.0,
                      ),
                      _buildLanguageOptions(
                        title: getString(
                          'language_and_currency_language',
                        ),
                      ),
                      _buildCurrencyOptions(
                        title: getString(
                          'language_and_currency_currency',
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                    ],
                  ),
                ),
              ),
              _buildButton(
                onPressCallback: () async {
                  await _setPreferences().then((isSet) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  });
                },
                backgroundColor: ColorUtil.hexToColor(
                  appConfigNotifier.appConfig.color.colorAccent,
                ),
                title: getString('language_and_currency_apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOptions({
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 10.0,
      ),
      child: FutureBuilder<LanguageResponse>(
        future: _futureLanguageList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_languageList.isEmpty) {
              _languageList.addAll(snapshot.data.data);
            }

            for (var element in _languageList) {
              if (element.code ==
                      Localizations.localeOf(context)
                          .languageCode
                          .toLowerCase() &&
                  _selectedLanguage == null) {
                _selectedLanguage = element;
                break;
              }
            }

            if (_selectedLanguage == null) {
              _selectedLanguage = _languageList.first;
            }

            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: kRegularTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                DropdownButton<Language>(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                  items: _languageList.map((Language dropdownItem) {
                    return DropdownMenuItem<Language>(
                      value: dropdownItem,
                      child: Text(dropdownItem.name),
                    );
                  }).toList(),
                  onChanged: (Language newlySelectedValue) {
                    setState(() {
                      _selectedLanguage = newlySelectedValue;
                    });
                  },
                  value: _selectedLanguage != null ? _selectedLanguage : null,
                  underline: SizedBox(),
                  isExpanded: false,
                ),
              ],
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCurrencyOptions({
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 10.0,
      ),
      child: FutureBuilder<CurrencyResponse>(
        future: _futureCurrencyList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_currencyList.isEmpty) {
              _currencyList.addAll(snapshot.data.data);
            }

            if (_selectedCurrency == null) {
              _selectedCurrency = _currencyList.first;
            }

            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: kRegularTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                DropdownButton<Currency>(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                  items: _currencyList.map((Currency dropdownItem) {
                    return DropdownMenuItem<Currency>(
                      value: dropdownItem,
                      child: Text(dropdownItem.name),
                    );
                  }).toList(),
                  onChanged: (Currency newlySelectedValue) {
                    setState(() {
                      _selectedCurrency = newlySelectedValue;
                    });
                  },
                  value: _selectedCurrency != null ? _selectedCurrency : null,
                  underline: SizedBox(),
                  isExpanded: false,
                ),
              ],
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          padding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onPressed: onPressCallback,
          color: backgroundColor,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _setPreferences() async {
    bool isLanguageChanged = await _appLanguage.changeLanguage(
      Locale(_selectedLanguage.code),
    );

    bool isCurrencyChanged = await SharedPrefUtil.writeString(
      kKeyCurrency,
      _selectedCurrency.code,
    );

    return isLanguageChanged && isCurrencyChanged;
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}
