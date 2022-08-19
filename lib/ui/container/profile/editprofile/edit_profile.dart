import 'dart:io';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/profile.dart';
import 'package:azzoa_grocery/data/remote/response/profile_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/container/profile/password/change_password.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String provider;

  EditProfilePage({this.provider});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isLoading = false;

  Future<ProfileResponse> _loadProfile;

  TextEditingController _userNameController;
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _phoneController;

  String _userName, _name, _email, _phone;

  File _imageFile;
  final _picker = ImagePicker();

  AppConfigNotifier appConfigNotifier;

  Future getImageFromGallery() async {
    final pickedFile = await _picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 720,
      maxHeight: 557.42,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future getImageFromCamera() async {
    final pickedFile = await _picker.getImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 720,
      maxHeight: 557.42,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();

    if (response.isEmpty) {
      return;
    }

    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        setState(() {
          _imageFile = null;
        });

        ToastUtil.show(getString('edit_profile_pick_image_error'));
      } else {
        setState(() {
          _imageFile = File(response.file.path);
        });
      }
    } else {
      setState(() {
        _imageFile = null;
      });

      ToastUtil.show(getString('edit_profile_pick_image_error'));
    }
  }

  @override
  void initState() {
    _userNameController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    _userName = kDefaultString;
    _name = kDefaultString;
    _email = kDefaultString;
    _phone = kDefaultString;

    super.initState();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false);
    _loadProfile = NetworkHelper.on().getProfile(
      context,
    );

    super.didChangeDependencies();
  }

  GestureDetector buildImagePreview(String imageUrl) {
    return GestureDetector(
      onTap: () {
        getImageFromGallery();
      },
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 50,
        backgroundImage:
            _imageFile == null ? NetworkImage(imageUrl) : FileImage(_imageFile),
      ),
    );
  }

  Widget buildAddingOption(
    VoidCallback onPressCallback,
    IconData iconData,
  ) {
    return GestureDetector(
      onTap: onPressCallback,
      child: Card(
        shape: CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            iconData,
            color: kSecondaryTextColor,
            size: 24.0,
          ),
        ),
      ),
    );
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
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Color(0xFFF9FAFB),
          elevation: 0.0,
          title: Text(
            getString('edit_profile_update'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Color(0xFFF9FAFB),
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : FutureBuilder(
                  future: _loadProfile,
                  builder: (context, AsyncSnapshot<ProfileResponse> snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data.status != null &&
                        snapshot.data.status == 200 &&
                        snapshot.data.data.jsonObject != null) {
                      Profile profile = snapshot.data.data.jsonObject;

                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        if (this.mounted) {
                          this.setState(() {
                            if (_name.isEmpty && _nameController.text.isEmpty) {
                              _name = profile.name;
                              _nameController.text = profile.name;
                            }

                            if (_userName.isEmpty &&
                                _userNameController.text.isEmpty) {
                              _userName = profile.username;
                              _userNameController.text = profile.username;
                            }

                            if (_email.isEmpty &&
                                _emailController.text.isEmpty) {
                              _email = profile.email;
                              _emailController.text = profile.email;
                            }

                            if (_phone.isEmpty &&
                                _phoneController.text.isEmpty) {
                              _phone = profile.phone;
                              _phoneController.text = profile.phone;
                            }
                          });
                        }
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(
                                  16.0,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    if (profile.avatar != null)
                                      buildProfilePictureSection(profile),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32.0,
                                        right: 32.0,
                                        top: 0.0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          buildAddingOption(
                                            () {
                                              getImageFromGallery();
                                            },
                                            Icons.photo,
                                          ),
                                          buildAddingOption(
                                            () {
                                              getImageFromCamera();
                                            },
                                            Icons.camera,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32.0,
                                    ),
                                    buildNameAttribute(
                                      getString('name'),
                                    ),
                                    buildUserNameAttribute(
                                      getString('user_name'),
                                    ),
                                    buildEmailAttribute(
                                      getString('email'),
                                    ),
                                    buildPhoneAttribute(
                                      getString('phone'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 48.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                onPressed: () {
                                  _updateProfile();
                                },
                                color: ColorUtil.hexToColor(
                                  appConfigNotifier
                                      .appConfig.color.buttonColor_2,
                                ),
                                child: Text(
                                  getString('save'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: 16.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 48.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                onPressed: (widget.provider != null &&
                                        widget.provider.trim().isNotEmpty &&
                                        (widget.provider.trim() == kGoogle ||
                                            widget.provider.trim() ==
                                                kFacebook))
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ChangePasswordPage();
                                            },
                                          ),
                                        );
                                      },
                                color: ColorUtil.hexToColor(
                                  appConfigNotifier.appConfig.color.colorAccent,
                                ),
                                child: Text(
                                  getString('edit_profile_change_password'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      String errorMessage = getString('something_went_wrong');

                      if (snapshot.hasError &&
                          snapshot.error is AppException &&
                          snapshot.error.toString().trim().isNotEmpty) {
                        errorMessage = snapshot.error.toString().trim();
                      }

                      return buildErrorBody(errorMessage);
                    }

                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget buildProfilePictureSection(Profile profile) {
    return Platform.isAndroid
        ? FutureBuilder(
            future: retrieveLostData(),
            builder: (
              BuildContext context,
              AsyncSnapshot<void> snapshot,
            ) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.done:
                  return buildImagePreview(
                    profile.avatar,
                  );
                default:
                  if (snapshot.hasError) {
                    ToastUtil.show(getString('edit_profile_pick_image_error'));
                  }

                  return buildImagePreview(
                    profile.avatar,
                  );
              }
            },
          )
        : buildImagePreview(
            profile.avatar,
          );
  }

  Future buildDialogAndShow(
    BuildContext context,
    String title,
    TextEditingController controller,
    TextInputType inputType,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: kCommonBackgroundColor,
          child: Container(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
                bottom: 32.0,
                left: 32.0,
                right: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: kRegularTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextFormField(
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
                      hintText: getString('edit_profile_value'),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: kSecondaryTextColor,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: kRegularTextColor,
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ),
                    controller: controller,
                  ),
                  SizedBox(height: 16.0),
                  FlatButton(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed: () {
                      if (validateCurrentInput(inputType, controller)) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    color: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.buttonColor_2,
                    ),
                    child: Text(
                      getString('ok'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool validateCurrentInput(
    TextInputType inputType,
    TextEditingController controller,
  ) {
    if (inputType == TextInputType.name) {
      if (controller.text.trim().isEmpty) {
        ToastUtil.show(getString('please_fill_up_the_field'));
        return false;
      } else {
        return true;
      }
    } else if (inputType == TextInputType.phone) {
      RegExp regExpPhone = RegExp(kRegExpPhone);

      if (controller.text.trim().isEmpty) {
        ToastUtil.show(getString('please_fill_up_the_field'));
        return false;
      } else if (!regExpPhone.hasMatch(controller.text.trim())) {
        ToastUtil.show(getString('provide_valid_phone'));
        return false;
      } else {
        return true;
      }
    } else if (inputType == TextInputType.emailAddress) {
      RegExp regExpEmail = RegExp(kRegExpEmail);

      if (controller.text.trim().isEmpty) {
        ToastUtil.show(getString('please_fill_up_the_field'));
        return false;
      } else if (!regExpEmail.hasMatch(controller.text.trim())) {
        ToastUtil.show(getString('provide_valid_email'));
        return false;
      } else {
        return true;
      }
    } else {
      if (controller.text.trim().isEmpty) {
        ToastUtil.show(getString('please_fill_up_the_field'));
        return false;
      } else if (controller.text.trim().contains(kSpaceString)) {
        ToastUtil.show(getString('registration_username_space_error'));
        return false;
      } else {
        return true;
      }
    }
  }

  Widget buildNameAttribute(String key) {
    return InkWell(
      onTap: () async {
        await buildDialogAndShow(
          context,
          key,
          _nameController,
          TextInputType.name,
        ).then(
          (result) {
            if (this.mounted) {
              this.setState(() {
                if (result != null && result is bool && result) {
                  _name = _nameController.text;
                } else {
                  _nameController.text = _name;
                }
              });
            }
          },
        );
      },
      child: buildItem(key, _name),
    );
  }

  Widget buildUserNameAttribute(String key) {
    return InkWell(
      onTap: () async {
        await buildDialogAndShow(
          context,
          key,
          _userNameController,
          TextInputType.text,
        ).then(
          (result) {
            if (this.mounted) {
              this.setState(() {
                if (result != null && result is bool && result) {
                  _userName = _userNameController.text;
                } else {
                  _userNameController.text = _userName;
                }
              });
            }
          },
        );
      },
      child: buildItem(key, _userName),
    );
  }

  Widget buildEmailAttribute(String key) {
    return InkWell(
      onTap: () async {
        await buildDialogAndShow(
          context,
          key,
          _emailController,
          TextInputType.emailAddress,
        ).then(
          (result) {
            if (this.mounted) {
              this.setState(() {
                if (result != null && result is bool && result) {
                  _email = _emailController.text;
                } else {
                  _emailController.text = _email;
                }
              });
            }
          },
        );
      },
      child: buildItem(key, _email),
    );
  }

  Widget buildPhoneAttribute(String key) {
    return InkWell(
      onTap: () async {
        await buildDialogAndShow(
          context,
          key,
          _phoneController,
          TextInputType.phone,
        ).then(
          (result) {
            if (this.mounted) {
              this.setState(() {
                if (result != null && result is bool && result) {
                  _phone = _phoneController.text;
                } else {
                  _phoneController.text = _phone;
                }
              });
            }
          },
        );
      },
      child: buildItem(key, _phone),
    );
  }

  Padding buildItem(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Card(
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  key,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.5),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
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

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  bool _validateUserData() {
    RegExp regExpEmail = RegExp(kRegExpEmail);
    RegExp regExpPhone = RegExp(kRegExpPhone);

    if (_nameController.text.trim().isEmpty ||
        _userNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ToastUtil.show(getString('please_fill_up_all_the_fields'));
      return false;
    } else if (!regExpEmail.hasMatch(_emailController.text.trim())) {
      ToastUtil.show(getString('provide_valid_email'));
      return false;
    } else if (!regExpPhone.hasMatch(_phoneController.text.trim())) {
      ToastUtil.show(getString('provide_valid_phone'));
      return false;
    } else if (_userNameController.text.trim().contains(kSpaceString)) {
      ToastUtil.show(getString('registration_username_space_error'));
      return false;
    } else {
      return true;
    }
  }

  void _updateProfile() async {
    if (_validateUserData()) {
      setState(() {
        isLoading = true;
      });

      try {
        ProfileResponse response = await NetworkHelper.on().updateProfile(
          context,
          _userNameController.text.trim(),
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          image: _imageFile,
        );

        if (this.mounted) {
          setState(() {
            isLoading = false;
          });
        }

        if (response != null &&
            response.status != null &&
            response.status == 200) {
          ToastUtil.show(getString('edit_profile_update_successful'));

          Navigator.of(context).pop(true);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(getString('edit_profile_update_error'));
        }
      }
    }
  }
}
