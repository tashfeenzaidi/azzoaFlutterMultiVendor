import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:azzoa_grocery/data/remote/response/shop_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/vendors/vendor_details.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class NearbyShopsPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  NearbyShopsPage({
    @required this.latitude,
    @required this.longitude,
  });

  @override
  _NearbyShopsPageState createState() => _NearbyShopsPageState();
}

class _NearbyShopsPageState extends State<NearbyShopsPage> {
  bool isLoading = false;
  Future<ShopListResponse> _loadShops;
  GoogleMapController mapController;
  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
    _loadShops = NetworkHelper.on().getNearbyShops(
      context,
      widget.latitude,
      widget.longitude,
    );
    super.didChangeDependencies();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('nearby_shops'),
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
              : buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return FutureBuilder(
      future: _loadShops,
      builder: (context, AsyncSnapshot<ShopListResponse> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200) {
          List<Shop> shopList = snapshot.data.data.jsonArray;
          List<Marker> markerList = [];
          LatLng currentPosition = LatLng(widget.latitude, widget.longitude);

          shopList.forEach((item) {
            try {
              double latitude = double.parse(item.latitude);
              double longitude = double.parse(item.longitude);

              markerList.add(
                Marker(
                  markerId: MarkerId(item.name),
                  position: LatLng(
                    latitude,
                    longitude,
                  ),
                  infoWindow: InfoWindow(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VendorDetailsPage(
                            shopId: item.id.toString(),
                          ),
                        ),
                      );
                    },
                    title: item.name,
                    snippet: item.address,
                  ),
                ),
              );
            } catch (e) {
              // Do nothing for now
            }
          });

          if (shopList.isEmpty) {
            ToastUtil.show(getString('no_shop_found'));
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: 12.0,
            ),
            markers: markerList.toSet(),
          );
        }

        if (snapshot.hasError) {
          String errorMessage = getString('something_went_wrong');

          if (snapshot.hasError &&
              snapshot.error is AppException &&
              snapshot.error.toString().trim().isNotEmpty) {
            errorMessage = snapshot.error.toString().trim();
          }

          return buildErrorBody(errorMessage);
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
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
}
