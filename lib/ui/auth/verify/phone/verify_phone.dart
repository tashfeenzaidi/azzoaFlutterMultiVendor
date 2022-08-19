import 'dart:async';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/container/home/homepage.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyPhonePage extends StatefulWidget {
  @override
  _VerifyPhonePageState createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> with CodeAutoFill {
  TextEditingController _codeController;
  bool isLoading = false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: kSecondaryTextColor),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  Timer _timer;
  int _remainingSeconds;

  String twoDigits(int number) => number.toString().padLeft(2, "0");

  void startTimer() {
    _remainingSeconds = 120;
    if (_timer != null) {
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

  bool hasError, hasSent;
  String error;

  void sendVerificationSms() async {
    hasSent = true;
    KeyboardUtil.hideKeyboard(context);

    setState(() {
      isLoading = true;
    });

    try {
      final signature = await SmsAutoFill().getAppSignature;

      BaseResponse response = await NetworkHelper.on().sendVerificationSms(
        context,
        signature,
      );

      if (response != null && response.status == 200) {
        setState(() {
          hasError = false;
          isLoading = false;
        });

        if (response.message != null && response.message.trim().isNotEmpty) {
          ToastUtil.show(response.message);
        }

        startTimer();
      } else {
        if (response != null &&
            response.message != null &&
            response.message.trim().isNotEmpty) {
          error = response.message;
        } else {
          error = getString('otp_sending_error');
        }

        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is AppException &&
          e.toString() != null &&
          e.toString().trim().isNotEmpty) {
        error = e.toString().trim();
      } else {
        error = getString('otp_sending_error');
      }

      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _codeController.dispose();

    // Dispose listening to the coming sms
    cancel();
    unregisterListener();
  }

  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
    if (!hasSent) sendVerificationSms();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    hasError = false;
    hasSent = false;
    error = kDefaultString;
    _remainingSeconds = 120;

    // To get verification code from sms
    listenForCode();
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
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            getString('phone_otp_sending'),
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
                  : (hasError ? buildErrorBody(error) : buildMainBody()),
            ),
          ],
        ),
      ),
    );
  }

  Center buildErrorBody(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      ),
    );
  }

  SingleChildScrollView buildMainBody() {
    Duration duration = Duration(seconds: _remainingSeconds);
    return SingleChildScrollView(
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
                        left: 48.0,
                        right: 48.0,
                      ),
                      child: Text(
                        getString('phone_otp_sent'),
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
                      submittedFieldDecoration: _pinPutDecoration,
                      followingFieldDecoration: _pinPutDecoration,
                      selectedFieldDecoration: _pinPutDecoration,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (_remainingSeconds != 0)
                          Text(
                            "${getString('expires_in')} ${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kSecondaryTextColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        if (_remainingSeconds != 0)
                          SizedBox(
                            width: 16.0,
                          ),
                        InkWell(
                          onTap: () {
                            _codeController.clear();
                            listenForCode();
                            sendVerificationSms();
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
                                getString('resend'),
                                style: TextStyle(
                                  color: ColorUtil.hexToColor(
                                    appConfigNotifier
                                        .appConfig.color.colorAccent,
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
                      _verifyPhone();
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
    } else if (_codeController.text.trim().length < 6) {
      ToastUtil.show(getString('otp_length_error'));
      return false;
    } else {
      return true;
    }
  }

  void _verifyPhone() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        BaseResponse response = await NetworkHelper.on().verifyPhone(
          context,
          _codeController.text.trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (response != null && response.status == 200) {
          String subtitle;

          if (response.message != null && response.message.trim().isNotEmpty) {
            subtitle = response.message;
          } else {
            subtitle = getString('phone_verified_successfully');
          }

          NetworkHelper.isVerifyingPhone = false;
          congratulateTheUser(subtitle);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('phone_otp_verify_error'),
          );
        }
      }
    }
  }

  void congratulateTheUser(String subtitle) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ), //this right here
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFC2E998), Color(0xFF02CC87)],
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.done,
                        size: 24.0,
                        color: Color(0xFFC2E998),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                    ),
                    child: Text(
                      getString('congratulations'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 32.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          bottom: 12.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        color: Colors.white.withOpacity(0.3),
                        child: Text(
                          getString('later'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      FlatButton(
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          bottom: 12.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        color: Colors.white,
                        child: Text(
                          getString('login_sign_in'),
                          style: TextStyle(
                            color: Color(0xFF16A085),
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    ).then(
      (result) async {
        if (result != null && result is bool && result) {
          await SharedPrefUtil.writeBoolean(
            kKeyIsLoggedIn,
            true,
          );

          Navigator.pushAndRemoveUntil(
            context,
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
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  void codeUpdated() {
    cancel();

    if (this.mounted) {
      this.setState(() {
        _codeController.text = code;
      });
    }
  }
}
