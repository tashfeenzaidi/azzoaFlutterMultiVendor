import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/forgot_password_send_otp_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/auth/forgotpassword/verify/verify_otp.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class RequestForgotPasswordOtpPage extends StatefulWidget {
  @override
  _RequestForgotPasswordOtpPageState createState() =>
      _RequestForgotPasswordOtpPageState();
}

class _RequestForgotPasswordOtpPageState
    extends State<RequestForgotPasswordOtpPage> {
  TextEditingController _emailController;
  bool isLoading = false;
  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _emailController = TextEditingController();

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
            getString('forgot_password'),
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
                                            'forgot_password_enter_email'),
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
                                    controller: _emailController,
                                    hint: getString('email'),
                                    inputType: TextInputType.emailAddress,
                                    icon: Icon(
                                      Icons.email,
                                      color: Color(0xFF02AEFF),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32.0,
                                  ),
                                  buildButton(
                                    onPressCallback: () {
                                      _requestForgotPasswordOtp();
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
    RegExp regExpEmail = RegExp(kRegExpEmail);

    if (_emailController.text.trim().isEmpty) {
      ToastUtil.show(getString('please_fill_up_the_field'));
      return false;
    } else if (!regExpEmail.hasMatch(_emailController.text.trim())) {
      ToastUtil.show(getString('provide_valid_email'));
      return false;
    } else {
      return true;
    }
  }

  void _requestForgotPasswordOtp() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        ForgotPasswordSendOtpResponse response =
            await NetworkHelper.on().sendForgotPasswordOtp(
          context,
          _emailController.text.trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (response.message != null && response.message.trim().isNotEmpty) {
          ToastUtil.show(response.message);
        }

        if (response.status == 200) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerifyOtpPage(
                email: _emailController.text.trim(),
              ),
            ),
          );
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
}
