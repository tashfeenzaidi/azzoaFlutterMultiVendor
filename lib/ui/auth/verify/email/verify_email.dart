import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/container/home/homepage.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  TextEditingController _codeController;
  bool isLoading = false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: kSecondaryTextColor),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  bool hasError, hasSent;
  String error;

  void sendVerificationEmail() async {
    hasSent = true;
    KeyboardUtil.hideKeyboard(context);

    setState(() {
      isLoading = true;
    });

    try {
      BaseResponse response = await NetworkHelper.on().sendVerificationEmail(
        context,
      );

      if (response != null && response.status == 200) {
        setState(() {
          hasError = false;
          isLoading = false;
        });

        if (response.message != null && response.message.trim().isNotEmpty) {
          ToastUtil.show(response.message);
        }
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
    _codeController.dispose();
    super.dispose();
  }

  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
    if (!hasSent) sendVerificationEmail();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    hasError = false;
    hasSent = false;
    error = kDefaultString;
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
          title: Text(
            getString('email_otp_sending'),
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
                        getString('email_otp_sent'),
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
                    height: 32.0,
                  ),
                  buildButton(
                    onPressCallback: () {
                      _verifyEmail();
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

  void _verifyEmail() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        BaseResponse response = await NetworkHelper.on().verifyEmail(
          context,
          _codeController.text.trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (response != null && response.status == 200) {
          if (response.message != null && response.message.trim().isNotEmpty) {
            ToastUtil.show(response.message);
          }

          NetworkHelper.isVerifyingEmail = false;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
                (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('email_otp_verify_error'),
          );
        }
      }
    }
  }
}
