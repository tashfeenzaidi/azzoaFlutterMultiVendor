import 'dart:async';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/forgot_password_send_otp_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/auth/forgotpassword/reset/reset_password.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;

  VerifyOtpPage({
    @required this.email,
  });

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  TextEditingController _codeController;
  bool isLoading = false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: kSecondaryTextColor),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  AppConfigNotifier appConfigNotifier;
  Timer _timer;
  int _remainingSeconds;
  String twoDigits(int number) => number.toString().padLeft(2, "0");

  void startTimer() {
    _remainingSeconds = 120;
    if(_timer != null) {
      _timer.cancel();
    }

    const oneSecond = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSecond,
      (Timer timer) => setState(
        () {
          if (_remainingSeconds < 1) {
            timer.cancel();
          } else {
            _remainingSeconds = _remainingSeconds - 1;
          }
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
  }

  @override
  void dispose() {
    super.dispose();
    _codeController.dispose();
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(seconds: _remainingSeconds);
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
            getString('verify_otp_title'),
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
                                        left: 16.0,
                                        right: 16.0,
                                      ),
                                      child: Text(
                                        getString('verify_otp_provide_otp'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 32.0,
                                        left: 16.0,
                                        right: 16.0,
                                      ),
                                      child: Text(
                                        "${getString('verify_otp_sent')} ${widget.email}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: kSecondaryTextColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0,
                                    ),
                                    child: PinPut(
                                      fieldsCount: 6,
                                      controller: _codeController,
                                      submittedFieldDecoration:
                                          _pinPutDecoration,
                                      followingFieldDecoration:
                                          _pinPutDecoration,
                                      selectedFieldDecoration:
                                          _pinPutDecoration,
                                      textStyle: TextStyle(
                                        color: kRegularTextColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      onSubmit: (String pin) {},
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        if(_remainingSeconds != 0)
                                          Text(
                                            "${getString('expires_in')} ${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: kSecondaryTextColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        if(_remainingSeconds != 0)
                                        SizedBox(
                                          width: 16.0,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _resendOtp();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: ColorUtil.hexToColor(
                                                appConfigNotifier.appConfig.color.colorAccent,
                                              ).withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 8.0,
                                              ),
                                              child: Text(
                                                getString('resend') +  " OTP",
                                                style: TextStyle(
                                                  color: ColorUtil.hexToColor(
                                                    appConfigNotifier.appConfig.color.colorAccent,
                                                  ),
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.left,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32.0,
                                  ),
                                  buildButton(
                                    onPressCallback: () {
                                      _checkAndVerifyOtp();
                                    },
                                    backgroundColor: ColorUtil.hexToColor(
                                      appConfigNotifier
                                          .appConfig.color.colorAccent,
                                    ),
                                    title: getString('next'),
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
    if (_codeController.text.trim().isEmpty) {
      ToastUtil.show(getString('please_fill_up_the_field'));
      return false;
    } else {
      return true;
    }
  }

  void _checkAndVerifyOtp() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(
            email: widget.email,
            otp: _codeController.text.trim(),
          ),
        ),
      );
    }
  }

  void _resendOtp() async {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        ForgotPasswordSendOtpResponse response =
        await NetworkHelper.on().sendForgotPasswordOtp(
          context,
          widget.email,
        );

        setState(() {
          isLoading = false;
        });

        if (response.message != null && response.message.trim().isNotEmpty) {
          ToastUtil.show(response.message);
        }

        if (response.status == 200) {
          startTimer();
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('forgot_password_error'),
          );
        }
      }
  }
}
