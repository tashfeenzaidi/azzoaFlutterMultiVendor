import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/currency.dart';
import 'package:azzoa_grocery/data/remote/model/language.dart';
import 'package:azzoa_grocery/data/remote/model/profile.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/response/currency_response.dart';
import 'package:azzoa_grocery/data/remote/response/language_response.dart';
import 'package:azzoa_grocery/data/remote/response/profile_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/help/help.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<LanguageResponse> _futureLanguageList;
  Future<CurrencyResponse> _futureCurrencyList;
  Future<ProfileResponse> _loadProfile;

  List<Language> _languageList = [];
  List<Currency> _currencyList = [];

  Currency _selectedCurrency;
  Language _selectedLanguage;
  AppThemeAndLanguage _appLanguage;
  bool _isNotificationsEnabled;
  bool isLoading = false;
  dynamic balance = 10;

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
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    _futureLanguageList = NetworkHelper.on().getLanguageList(context);
    _futureCurrencyList = NetworkHelper.on().getCurrencyList(context);
    _loadProfile = NetworkHelper.on().getProfile(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _appLanguage = Provider.of<AppThemeAndLanguage>(context);

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
            getString('settings_toolbar_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: kCommonBackgroundColor,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
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
                              'settings_language',
                            ),
                          ),
                          _buildCurrencyOptions(
                            title: getString(
                              'settings_currency',
                            ),
                          ),
                          _buildNotificationOption(
                            title: getString(
                              'settings_notifications',
                            ),
                          ),
                          _buildHelpOption(
                              title: getString(
                                'settings_help',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HelpPage(),
                                  ),
                                );
                              }),
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
                        Navigator.pop(context);
                      });
                    },
                    backgroundColor: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ),
                    title: getString('settings_apply'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLanguageOptions({
    String title,
  }) {
    setState(() {

    });
    return FutureBuilder<LanguageResponse>(
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

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: kRegularTextColor,
                        fontSize: 14.0,
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
                      value:
                          _selectedLanguage != null ? _selectedLanguage : null,
                      underline: SizedBox(),
                      isExpanded: false,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildCurrencyOptions({
    String title,
  }) {
    return FutureBuilder<CurrencyResponse>(
      future: _futureCurrencyList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (_currencyList.isEmpty) {
            _currencyList.addAll(snapshot.data.data);
          }

          if (_selectedCurrency == null) {
            _selectedCurrency = _currencyList.first;
          }

          return Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 8.0,
            ),
            child: Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: kRegularTextColor,
                        fontSize: 14.0,
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
                      value:
                          _selectedCurrency != null ? _selectedCurrency : null,
                      underline: SizedBox(),
                      isExpanded: false,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildNotificationOption({
    String title,
  }) {
    return FutureBuilder(
      future: _loadProfile,
      builder: (context, AsyncSnapshot<ProfileResponse> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200) {
          Profile profile = snapshot.data.data.jsonObject;
          balance =profile.balance;
          if (_isNotificationsEnabled == null) {
            _isNotificationsEnabled = profile.pushNotification == 1;
          }
          return Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 8.0,
            ),
            child: Card(
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: kRegularTextColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Switch(
                      value: _isNotificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isNotificationsEnabled = value;
                        });
                      },
                      inactiveTrackColor: Color(0xFFEBEBEB),
                      activeTrackColor: Color(0xFFEBEBEB),
                      activeColor: Color(0xFF14BC9F),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildHelpOption({
    String title,
    VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
      ),
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: kRegularTextColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
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

    await _setNotification();

    return isLanguageChanged && isCurrencyChanged;
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  Future<void> _setNotification() async {
    setState(() {
      isLoading = true;
    });

    try {
      BaseResponse response = await NetworkHelper.on().setNotification(
        context,
        _isNotificationsEnabled,
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        ToastUtil.show(response.message);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('settings_set_notification_state_error'),
        );
      }
    }
  }
}
