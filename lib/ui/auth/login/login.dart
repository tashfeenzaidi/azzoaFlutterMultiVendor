import 'dart:convert';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/login_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/auth/forgotpassword/request/request_otp.dart';
import 'package:azzoa_grocery/ui/auth/registration/registration.dart';
import 'package:azzoa_grocery/ui/auth/verify/phone/verify_phone.dart';
import 'package:azzoa_grocery/ui/container/home/homepage.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/auth.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TextEditingController _emailController;
  TextEditingController _passwordController;
  bool isLoading = false;
  AppConfigNotifier appConfigNotifier;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    super.initState();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    _checkAndGetLocation();
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
                                top: 48.0,
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
                                top: 24.0,
                                bottom: 16.0,
                              ),
                              child: Text(
                                "${getString('login_welcome')}\n${appConfigNotifier.appConfig.name}",
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
                                getString('login_to_continue'),
                                style: TextStyle(
                                  color: kSecondaryTextColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          buildTextFormField(
                            controller: _emailController,
                            hint: getString('email'),
                            inputType: TextInputType.emailAddress,
                            icon: Icon(
                              Icons.email,
                              color: Color(0xFF02AEFF),
                            ),
                          ),
                          buildTextFormField(
                            controller: _passwordController,
                            hint: getString('password'),
                            inputType: TextInputType.visiblePassword,
                            icon: Icon(
                              Icons.lock,
                              color: Color(0xFF14BC9F),
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 32.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RequestForgotPasswordOtpPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  getString('login_forgot_password'),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: kSecondaryTextColor,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          buildButton(
                            onPressCallback: () {
                              _login();
                            },
                            backgroundColor: ColorUtil.hexToColor(
                              appConfigNotifier.appConfig.color.colorAccent,
                            ),
                            title: getString('login_sign_in'),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Center(
                            child: buildSocialLoginRow(),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => RegistrationPage(),
                                  ),
                                );
                              },
                              child: Text(
                                getString('login_no_account'),
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

  Padding buildSocialLoginRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Column(
        children: <Widget>[
          Text(
            getString('login_or'),
            style: TextStyle(
              color: kSecondaryTextColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  _loginWithSocialMedia(kGoogle);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0x12FF3D00),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 24.0,
                  ),
                  child: Image.asset(
                    'images/ic_google_small.png',
                    fit: BoxFit.fitHeight,
                    height: 20.0,
                  ),
                ),
              ),
              SizedBox(
                width: 16.0,
              ),
              InkWell(
                onTap: () {
                  _loginWithSocialMedia(kFacebook);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0x122C32BE),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 24.0,
                  ),
                  child: Image.asset(
                    'images/ic_facebook_small.png',
                    fit: BoxFit.fitHeight,
                    height: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ],
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
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 0.0,
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
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.0,
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

  void _loginWithSocialMedia(String driver) async {
    String userId, name, email;

    try {
      if (driver == kGoogle) {
        googleSignIn.signOut();
        final GoogleSignInAccount googleAccount = await googleSignIn.signIn();

        if (googleAccount != null) {
          userId = googleAccount.id;
          name = googleAccount.displayName;
          email = googleAccount.email;
        } else {
          return;
        }
      } else if (driver == kFacebook) {
        FacebookLoginResult loginResult = await facebookLogin.logIn(['email']);
        switch (loginResult.status) {
          case FacebookLoginStatus.cancelledByUser:
            return;

          case FacebookLoginStatus.error:
            throw Exception(loginResult.errorMessage);
            break;

          case FacebookLoginStatus.loggedIn:
            final token = loginResult.accessToken.token;
            final graphResponse = await http.get(
                'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
            final profile = json.decode(graphResponse.body);

            if (profile != null) {
              userId = profile['id'];
              name = profile['name'];
              email = profile['email'];
            }
            break;

          default:
            break;
        }
      }

      if (userId == null || name == null || email == null) {
        ToastUtil.show(getString('login_failed_fetching_token'));
        return;
      }

      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        await _firebaseMessaging.getToken().then((String deviceToken) async {
          if (deviceToken != null && deviceToken.isNotEmpty) {
            LoginResponse response =
                await NetworkHelper.on().loginViaSocialMedia(
              context,
              driver,
              userId,
              name,
              email,
              deviceToken,
            );

            setState(() {
              isLoading = false;
            });

            if (response != null &&
                response.token != null &&
                response.tokenType != null) {
              await SharedPrefUtil.writeString(
                kKeyAccessToken,
                response.tokenType + kSpaceString + response.token,
              );

              await SharedPrefUtil.writeBoolean(
                kKeyIsLoggedIn,
                true,
              );

              await SharedPrefUtil.writeString(
                kKeyProvider,
                driver,
              );

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            }
          } else {
            ToastUtil.show(getString('login_failed_fetching_token'));
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('login_error_login'),
          );
        }
      }
    } catch (e) {
      if (e != null && e.toString() != null && e.toString().isNotEmpty) {
        ToastUtil.show(e.toString());
      }
    }
  }

  bool _validateUserData() {
    RegExp regExpEmail = RegExp(kRegExpEmail);

    if (_emailController.text.trim().isEmpty &&
        _passwordController.text.trim().isEmpty) {
      ToastUtil.show(getString('please_fill_up_all_the_fields'));
      return false;
    } else if (_emailController.text.trim().isEmpty) {
      ToastUtil.show(getString('email_is_required'));
      return false;
    } else if (!regExpEmail.hasMatch(_emailController.text.trim())) {
      ToastUtil.show(getString('provide_valid_email'));
      return false;
    } else if (_passwordController.text.trim().isEmpty) {
      ToastUtil.show(getString('password_is_required'));
      return false;
    } else if (_passwordController.text.trim().length < 8) {
      ToastUtil.show(getString('valid_password_length'));
      return false;
    } else {
      return true;
    }
  }

  void _login() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        await _firebaseMessaging.getToken().then((String token) async {
          if (token != null && token.isNotEmpty) {
            LoginResponse response = await NetworkHelper.on().login(
              context,
              _emailController.text.trim(),
              _passwordController.text.trim(),
              token,
            );

            setState(() {
              isLoading = false;
            });

            if (response != null &&
                response.token != null &&
                response.tokenType != null) {
              await SharedPrefUtil.writeString(
                kKeyAccessToken,
                response.tokenType + kSpaceString + response.token,
              );

              if (response.phoneVerifiedAt != null) {
                await SharedPrefUtil.writeBoolean(
                  kKeyIsLoggedIn,
                  true,
                );

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                  (route) => false,
                );
              } else {
                await SharedPrefUtil.writeBoolean(
                  kKeyIsLoggedIn,
                  false,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyPhonePage(),
                  ),
                );
              }
            }
          } else {
            ToastUtil.show(
              getString('login_failed_fetching_token'),
            );
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('login_error_login'),
          );
        }
      }
    }
  }
}
