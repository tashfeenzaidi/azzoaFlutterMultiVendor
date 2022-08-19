import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/response/address_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:provider/provider.dart';

class AddNewAddressPage extends StatefulWidget {
  final String pageTag;

  AddNewAddressPage({@required this.pageTag});

  @override
  _AddNewAddressPageState createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends State<AddNewAddressPage> {
  bool isLoading = false;
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _phoneController;
  TextEditingController _latitudeController;
  TextEditingController _longitudeController;
  TextEditingController _addressLine1Controller;
  TextEditingController _addressLine2Controller;
  TextEditingController _cityController;
  TextEditingController _stateController;
  TextEditingController _countryController;

  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
  }

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _countryController.text = 'BD';

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          brightness: Brightness.light,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: kInactiveColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('add_new_address_toolbar_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: kCommonBackgroundColor,
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            buildTextFormField(
                              controller: _nameController,
                              hint: getString('name'),
                              inputType: TextInputType.name,
                            ),
                            buildTextFormField(
                              controller: _emailController,
                              hint: getString('email'),
                              inputType: TextInputType.emailAddress,
                            ),
                            buildTextFormField(
                              controller: _phoneController,
                              hint: getString('phone'),
                              inputType: TextInputType.phone,
                            ),
                            buildTextFormField(
                              controller: _latitudeController,
                              hint: getString('latitude'),
                              inputType: TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              showPlacePicker: true,
                            ),
                            buildTextFormField(
                              controller: _longitudeController,
                              hint: getString('longitude'),
                              inputType: TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                            ),
                            buildTextFormField(
                              controller: _addressLine1Controller,
                              hint: getString('add_new_address_address_line_1'),
                              inputType: TextInputType.streetAddress,
                            ),
                            buildTextFormField(
                              controller: _addressLine2Controller,
                              hint: getString('add_new_address_address_line_2'),
                              inputType: TextInputType.streetAddress,
                            ),
                            buildTextFormField(
                              controller: _cityController,
                              hint: getString('add_new_address_city'),
                              inputType: TextInputType.streetAddress,
                            ),
                            buildTextFormField(
                              controller: _stateController,
                              hint: getString('add_new_address_state'),
                              inputType: TextInputType.streetAddress,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24.0,
                                16.0,
                                24.0,
                                0.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Text(
                                      getString('add_new_address_country'),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.only(
                                      top: 16.0,
                                    ),
                                    color: Colors.white,
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          CountryListPick(
                                            theme: CountryTheme(
                                              isShowFlag: true,
                                              isShowTitle: true,
                                              isShowCode: false,
                                              isDownIcon: false,
                                              showEnglishName: true,
                                            ),
                                            initialSelection: '+880',
                                            onChanged: (CountryCode code) {
                                              _countryController.text = code.code;
                                            },
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              width: double.infinity,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    buildButton(
                      onPressCallback: () {
                        _addAddress();
                      },
                      backgroundColor: ColorUtil.hexToColor(
                        appConfigNotifier.appConfig.color.colorAccent,
                      ),
                      title: getString('add_new_address_add_now'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
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

  Widget buildTextFormField({
    TextEditingController controller,
    String hint,
    TextInputType inputType,
    int maxLength,
    Icon icon,
    bool showPlacePicker = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hint,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showPlacePicker)
                  InkWell(
                    onTap: () async {
                      // LocationResult result = await showLocationPicker(
                      //   context,
                      //   kApiKeyGoogleMap,
                      //   myLocationButtonEnabled: true,
                      //   searchBarBoxDecoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(10.0),
                      //   ),
                      // );

                      // if (result.latLng != null) {
                      //   _latitudeController.text =
                      //       result.latLng.latitude.toString();
                      //   _longitudeController.text =
                      //       result.latLng.longitude.toString();
                      // }
                      //
                      // if (result.address != null &&
                      //     result.address.trim().isNotEmpty) {
                      //   _addressLine1Controller.text = result.address;
                      // }
                    },
                    child: Text(
                      getString('add_new_address_pick_from_map'),
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.only(
              top: 16.0,
            ),
            color: Colors.white,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: TextFormField(
                obscureText: inputType == TextInputType.visiblePassword,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
                keyboardType: inputType,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.3),
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
                ),
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateUserData() {
    RegExp regExpEmail = RegExp(kRegExpEmail);
    RegExp regExpPhone = RegExp(kRegExpPhone);

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _latitudeController.text.trim().isEmpty ||
        _longitudeController.text.trim().isEmpty ||
        _addressLine1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty) {
      ToastUtil.show(getString('please_fill_up_all_the_fields'));
      return false;
    } else if (!regExpEmail.hasMatch(_emailController.text.trim())) {
      ToastUtil.show(getString('provide_valid_email'));
      return false;
    } else if (!regExpPhone.hasMatch(_phoneController.text.trim())) {
      ToastUtil.show(getString('provide_valid_phone'));
      return false;
    } else {
      return true;
    }
  }

  void _addAddress() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        AddressResponse response = await NetworkHelper.on().addAddress(
          context,
          widget.pageTag,
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _countryController.text.trim(),
          _stateController.text.trim(),
          _cityController.text.trim(),
          _addressLine1Controller.text.trim(),
          _latitudeController.text.trim(),
          _longitudeController.text.trim(),
          streetAddress2: _addressLine2Controller.text.trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (response != null && response.status != null && response.status == 200) {
          ToastUtil.show(getString('add_new_address_added'));

          Navigator.of(context).pop(true);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('add_new_address_error'),
          );
        }
      }
    }
  }
}
