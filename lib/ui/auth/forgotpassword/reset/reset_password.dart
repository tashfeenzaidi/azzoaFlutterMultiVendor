import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/reset_password_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;

  ResetPasswordPage({
    @required this.email,
    @required this.otp,
  });

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController _newPasswordController;
  TextEditingController _confirmNewPasswordController;
  bool isLoading = false;

  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            getString('reset_password'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            SafeArea(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 32.0,
                              left: 16.0,
                              right: 16.0,
                            ),
                            child: Card(
                              elevation: 2.0,
                              child: Column(
                                children: <Widget>[
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 32.0,
                                        bottom: 16.0,
                                      ),
                                      child: Text(
                                        getString(
                                            'reset_password_enter_password'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  buildTextFormField(
                                    controller: _newPasswordController,
                                    hint: getString('new_password'),
                                    inputType: TextInputType.visiblePassword,
                                    icon: Icon(
                                      Icons.lock,
                                      color: kSecondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  buildTextFormField(
                                    controller: _confirmNewPasswordController,
                                    hint: getString('confirm_new_password'),
                                    inputType: TextInputType.visiblePassword,
                                    icon: Icon(
                                      Icons.lock,
                                      color: kSecondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32.0,
                                  ),
                                  buildButton(
                                    onPressCallback: () {
                                      _resetPassword();
                                    },
                                    backgroundColor: ColorUtil.hexToColor(
                                      appConfigNotifier.appConfig.color.colorAccent,
                                    ),
                                    title: getString('submit'),
                                  ),
                                  SizedBox(
                                    height: 32.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField({
    TextEditingController controller,
    String hint,
    TextInputType inputType,
    int maxLength,
    Icon icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 2.0, 32.0, 2.0),
      child: TextFormField(
        obscureText: inputType == TextInputType.visiblePassword,
        style: TextStyle(
          color: kSecondaryTextColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
        keyboardType: inputType,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: kSecondaryTextColor,
          ),
          labelText: hint,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: kSecondaryTextColor.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: kSecondaryTextColor.withOpacity(0.5),
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: kSecondaryTextColor.withOpacity(0.5),
            ),
          ),
          suffixIcon: icon != null ? icon : SizedBox.shrink(),
        ),
        controller: controller,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
      ),
    );
  }

  Widget buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return RaisedButton(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 48.0,
      ),
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
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  bool _validateUserData() {
    if (_newPasswordController.text.trim().isEmpty ||
        _confirmNewPasswordController.text.trim().isEmpty) {
      ToastUtil.show(getString('please_fill_up_all_the_fields'));
      return false;
    } else if (_newPasswordController.text.trim() !=
        _confirmNewPasswordController.text.trim()) {
      ToastUtil.show(getString('valid_password_not_matching'));
      return false;
    } else if (_newPasswordController.text.trim().length < 8) {
      ToastUtil.show(getString('valid_password_length'));
      return false;
    } else {
      return true;
    }
  }

  void _resetPassword() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        ResetPasswordResponse response = await NetworkHelper.on().resetPassword(
          context,
          widget.email,
          widget.otp,
          _newPasswordController.text.trim(),
          _confirmNewPasswordController.text.trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (response.message != null && response.message.trim().isNotEmpty) {
          ToastUtil.show(response.message);
        }

        if (response.status == 200) {
          int count = 0;
          Navigator.of(context).popUntil(
            (route) {
              count++;
              return count == 4;
            },
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('reset_password_error'),
          );
        }
      }
    }
  }
}
