import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/local/service/database_service.dart';
import 'package:azzoa_grocery/data/remote/model/profile.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/response/profile_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/address/view/view_address.dart';
import 'package:azzoa_grocery/ui/auth/login/login.dart';
import 'package:azzoa_grocery/ui/container/orderhistory/order_history.dart';
import 'package:azzoa_grocery/ui/container/profile/editprofile/edit_profile.dart';
import 'package:azzoa_grocery/ui/container/settings/settings.dart';
import 'package:azzoa_grocery/ui/container/transactionlist/transaction_list_screen.dart';
import 'package:azzoa_grocery/ui/container/wishlist/wish_list.dart';
import 'package:azzoa_grocery/ui/orders/trackingorders/tracking_orders.dart';
import 'package:azzoa_grocery/ui/vendors/followed/followed_vendors.dart';
import 'package:azzoa_grocery/ui/vendors/nearby/nearby_shops.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class ProfileMenuPage extends StatefulWidget {
  @override
  _ProfileMenuPageState createState() => _ProfileMenuPageState();
}

class _ProfileMenuPageState extends State<ProfileMenuPage> {
  bool isLoading = false;
  Future<ProfileResponse> _loadProfile;

  AppConfigNotifier appConfigNotifier;
  String currencyCode ;

  @override
  void initState()  {
    intiPref();
    super.initState();
  }

  void intiPref()async{
    currencyCode =
    await SharedPrefUtil.getString(
        kKeyCurrency);
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );

    _loadProfile = NetworkHelper.on().getProfile(
      context,
    );

    _checkAndGetLocation();

    super.didChangeDependencies();
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
  Widget build(BuildContext context) {

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: kCommonBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: kCommonBackgroundColor,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            getString('profile_menu_profile'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF000DFF).withOpacity(0.9449),
                      Color(0xFF6B73FF).withOpacity(0.3191),
                    ],
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).size.height / 3) * 2,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : FutureBuilder(
                      future: _loadProfile,
                      builder:
                          (context, AsyncSnapshot<ProfileResponse> snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data.status != null &&
                            snapshot.data.status == 200 &&
                            snapshot.data.data.jsonObject != null) {
                          Profile profile = snapshot.data.data.jsonObject;

                          return SafeArea(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        visitEditProfilePage(context);
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 45,
                                        backgroundImage: NetworkImage(
                                          profile.avatar,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      visitEditProfilePage(context);
                                    },
                                    child: Text(
                                      profile.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5.0,),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4)),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: Text(
                                      "Balance: ${profile.balance} $currencyCode",
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  buildMenu(context),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          String errorMessage = getString(
                            'something_went_wrong',
                          );

                          if (snapshot.hasError &&
                              snapshot.error is AppException &&
                              snapshot.error.toString().trim().isNotEmpty) {
                            errorMessage = snapshot.error.toString().trim();
                          }

                          return buildErrorBody(errorMessage);
                        }

                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  void visitEditProfilePage(BuildContext context) {
    SharedPrefUtil.getString(kKeyProvider).then((provider) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(provider: provider),
        ),
      ).then(
        (value) {
          if (value != null && value is bool && value && this.mounted) {
            this.setState(() {
              _loadProfile = NetworkHelper.on().getProfile(context);
            });
          }
        },
      );
    });
  }

  Widget buildMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 16.0,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            getItem(
              "images/ic_edit_profile.png",
              getString('profile_menu_edit_profile'),
              () {
                visitEditProfilePage(context);
              },
            ),
            getItem(
              "images/ic_shipping_address.png",
              getString('profile_menu_shipping_address'),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewAddressPage(
                      pageTag: "shipping",
                    ),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_shipping_address.png",
              getString('profile_menu_billing_address'),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewAddressPage(
                      pageTag: "billing",
                    ),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_wish_list.png",
              getString('profile_menu_wish_list'),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WishListPage(),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_order_history.png",
              getString('profile_menu_order_history'),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_track_order.png",
              getString('profile_menu_track_order'),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackingOrderListPage(),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_order_history.png",
              getString('transaction_list'),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionListPage(),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_wish_list.png",
              getString('vendors_followed'),
              () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowedVendorsPage(),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_store_locator.png",
              getString('profile_menu_store_locator'),
              () async {
                visitNearbyShops();
              },
            ),
            getItem(
              "images/ic_settings.png",
              getString('profile_menu_settings'),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
            ),
            getItem(
              "images/ic_log_out.png",
              getString('profile_menu_log_out'),
              () {
                _logOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getItem(String imagePath, String title, Function onPressCallback) {
    return InkWell(
      onTap: onPressCallback,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 24,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF8C8C8C),
              size: 16.0,
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
            color: Colors.white,
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

  void _logOut() async {
    try {
      if (this.mounted) {
        this.setState(() {
          isLoading = true;
        });
      }

      BaseResponse response = await NetworkHelper.on().logOut(context);

      if (this.mounted) {
        this.setState(() {
          isLoading = false;
        });
      }

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (response.message != null && response.message.trim().isNotEmpty) {
          ToastUtil.show(response.message);
        }

        String currencyCode = await SharedPrefUtil.getString(kKeyCurrency);
        String language = await SharedPrefUtil.getString(kKeyLanguage);

        await SharedPrefUtil.clear().then((value) async {
          await DatabaseService.on().clearDatabase();

          await SharedPrefUtil.writeString(
            kKeyCurrency,
            currencyCode,
          );

          await SharedPrefUtil.writeString(
            kKeyLanguage,
            language,
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false,
          );
        });
      }
    } catch (e) {
      if (this.mounted) {
        this.setState(() {
          isLoading = false;
        });
      }

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('profile_menu_log_out_error'),
        );
      }
    }
  }

  void visitNearbyShops() {
    if (appConfigNotifier.currentLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NearbyShopsPage(
            latitude: appConfigNotifier.currentLocation.latitude,
            longitude: appConfigNotifier.currentLocation.longitude,
          ),
        ),
      );
    } else {
      ToastUtil.show(getString('fetch_location_error'));
    }
  }
}
