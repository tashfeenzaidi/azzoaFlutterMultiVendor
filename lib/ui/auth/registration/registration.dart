import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/registration_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/auth/verify/phone/verify_phone.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TextEditingController _nameController;
  TextEditingController _userNameController;
  TextEditingController _phoneController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;

  bool isLoading = false;

  AppConfigNotifier appConfigNotifier;

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _userNameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
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
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 16.0,
                              ),
                              child: Image.network(
                                appConfigNotifier.appConfig.logo,
                                fit: BoxFit.contain,
                                height: 60.0,
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 16.0,
                                top: 24.0,
                              ),
                              child: Text(
                                getString('registration_lets_get_started'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 32.0,
                              ),
                              child: Text(
                                getString('registration_create_a_new_account'),
                                style: TextStyle(
                                  color: kSecondaryTextColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          buildTextFormField(
                            controller: _nameController,
                            hint: getString('registration_full_name'),
                            inputType: TextInputType.text,
                            icon: Icon(
                              Icons.account_circle,
                              color: Color(0xFFFEB71E),
                            ),
                          ),
                          buildTextFormField(
                            controller: _userNameController,
                            hint: getString('registration_user_name'),
                            inputType: TextInputType.text,
                            icon: Icon(
                              Icons.account_circle,
                              color: Color(0xFFFEB71E),
                            ),
                          ),
                          buildTextFormField(
                            controller: _emailController,
                            hint: getString('registration_your_email'),
                            inputType: TextInputType.emailAddress,
                            icon: Icon(
                              Icons.email,
                              color: Color(0xFF02AEFF),
                            ),
                          ),
                          buildTextFormField(
                            controller: _phoneController,
                            hint: getString('registration_phone_number'),
                            inputType: TextInputType.phone,
                            icon: Icon(
                              Icons.phone,
                              color: Color(0xFF02AEFF),
                            ),
                          ),
                          buildTextFormField(
                            controller: _passwordController,
                            hint: getString('registration_password'),
                            inputType: TextInputType.visiblePassword,
                            icon: Icon(
                              Icons.lock,
                              color: Color(0xFF14BC9F),
                            ),
                          ),
                          buildTextFormField(
                            controller: _confirmPasswordController,
                            hint: getString('registration_confirm_password'),
                            inputType: TextInputType.visiblePassword,
                            icon: Icon(
                              Icons.lock,
                              color: Color(0xFF14BC9F),
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          buildButton(
                            onPressCallback: () {
                              _registerTheUser();
                            },
                            backgroundColor: ColorUtil.hexToColor(
                              appConfigNotifier.appConfig.color.colorAccent,
                            ),
                            title: getString('registration_sign_up'),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                getString('registration_have_an_account'),
                                style: TextStyle(
                                  color: kSecondaryTextColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
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
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: TextFormField(
            obscureText: inputType == TextInputType.visiblePassword,
            style: TextStyle(
              color: kSecondaryTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
            keyboardType: inputType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 16.0,
              ),
              hintStyle: TextStyle(
                color: kSecondaryTextColor,
              ),
              hintText: hint,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              suffixIcon: icon != null ? icon : SizedBox.shrink(),
            ),
            controller: controller,
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxLength),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
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

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  bool _validateUserData() {
    RegExp regExpEmail = RegExp(kRegExpEmail);
    RegExp regExpPhone = RegExp(kRegExpPhone);

    if (_nameController.text.trim().isEmpty &&
        _userNameController.text.trim().isEmpty &&
        _emailController.text.trim().isEmpty &&
        _phoneController.text.trim().isEmpty &&
        _passwordController.text.trim().isEmpty &&
        _confirmPasswordController.text.trim().isEmpty) {
      ToastUtil.show(getString('registration_please_fill_up_all_the_fields'));
      return false;
    } else if (_nameController.text.trim().isEmpty) {
      ToastUtil.show(getString('name_is_required'));
      return false;
    } else if (_userNameController.text.trim().isEmpty) {
      ToastUtil.show(getString('username_is_required'));
      return false;
    } else if (_userNameController.text.trim().contains(kSpaceString)) {
      ToastUtil.show(getString('registration_username_space_error'));
      return false;
    } else if (_emailController.text.trim().isEmpty) {
      ToastUtil.show(getString('email_is_required'));
      return false;
    } else if (!regExpEmail.hasMatch(_emailController.text.trim())) {
      ToastUtil.show(getString('registration_please_enter_a_valid_email'));
      return false;
    } else if (_phoneController.text.trim().isEmpty) {
      ToastUtil.show(getString('phone_is_required'));
      return false;
    } else if (!regExpPhone.hasMatch(_phoneController.text.trim())) {
      ToastUtil.show(getString('registration_please_enter_a_valid_phone'));
      return false;
    } else if (_passwordController.text.trim().isEmpty) {
      ToastUtil.show(getString('password_is_required'));
      return false;
    } else if (_passwordController.text.trim().length < 8) {
      ToastUtil.show(getString('registration_passwords_should_have_length'));
      return false;
    } else if (_confirmPasswordController.text.trim().isEmpty) {
      ToastUtil.show(getString('confirm_password_is_required'));
      return false;
    } else if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ToastUtil.show(getString('registration_your_passwords_do_not_match'));
      return false;
    } else {
      return true;
    }
  }

  void _registerTheUser() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        await _firebaseMessaging.getToken().then((String token) async {
          if (token != null && token.isNotEmpty) {
            RegistrationResponse response = await NetworkHelper.on().register(
              context,
              _nameController.text.trim(),
              _userNameController.text.trim(),
              _emailController.text.trim(),
              _phoneController.text.trim(),
              _passwordController.text.trim(),
              _confirmPasswordController.text.trim(),
              token,
            );

            setState(() {
              isLoading = false;
            });

            if (response != null && response.status == 200) {
              await SharedPrefUtil.writeString(
                kKeyAccessToken,
                kPrefixAuthToken + response.token,
              );

              await SharedPrefUtil.writeBoolean(
                kKeyIsLoggedIn,
                false,
              );

              _nameController.clear();
              _userNameController.clear();
              _emailController.clear();
              _phoneController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPhonePage(),
                ),
              );
            }
          } else {
            ToastUtil.show(
              getString('fcm_token_error_could_not_receive_the_token'),
            );
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('registration_could_not_register_the_user'),
          );
        }
      }
    }
  }
}
