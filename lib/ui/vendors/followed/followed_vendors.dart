import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:azzoa_grocery/data/remote/response/shop_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/vendors/vendor_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class FollowedVendorsPage extends StatefulWidget {
  @override
  _FollowedVendorsPageState createState() => _FollowedVendorsPageState();
}

class _FollowedVendorsPageState extends State<FollowedVendorsPage> {
  bool isLoading = false;
  bool isListEmpty = false;
  bool _isLinearList = false;
  Color _gridListIconColor = kAccentColor;
  Color _linearListIconColor = kInactiveColor;

  Future<ShopListResponse> loadShops;

  AppConfigNotifier appConfigNotifier;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    _gridListIconColor = ColorUtil.hexToColor(
      appConfigNotifier.appConfig.color.colorAccent,
    );
    loadShops = NetworkHelper.on().getFollowedShops(
      context,
    );

    super.didChangeDependencies();
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
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('vendors_followed'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: kCommonBackgroundColor,
              ),
            ),
            SafeArea(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyPlaceholder() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  getString('no_item_found'),
                  style: TextStyle(
                    color: kRegularTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: FutureBuilder(
            future: loadShops,
            builder: (context, AsyncSnapshot<ShopListResponse> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.status != null &&
                  snapshot.data.status == 200) {
                if (snapshot.data.data.jsonArray.isEmpty) {
                  return buildEmptyPlaceholder();
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 16.0,
                          bottom: 16.0,
                          left: 16.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              kDefaultString,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                InkWell(
                                  child: Image.asset(
                                    "images/ic_linear_list.png",
                                    fit: BoxFit.fitHeight,
                                    height: 24.0,
                                    color: _linearListIconColor,
                                  ),
                                  onTap: () {
                                    if (this.mounted) {
                                      setState(() {
                                        _isLinearList = true;
                                        _linearListIconColor =
                                            ColorUtil.hexToColor(
                                          appConfigNotifier
                                              .appConfig.color.colorAccent,
                                        );
                                        _gridListIconColor = kInactiveColor;
                                      });
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                InkWell(
                                  child: Image.asset(
                                    "images/ic_grid_list.png",
                                    fit: BoxFit.fitHeight,
                                    height: 24.0,
                                    color: _gridListIconColor,
                                  ),
                                  onTap: () {
                                    if (this.mounted) {
                                      setState(() {
                                        _isLinearList = false;
                                        _gridListIconColor =
                                            ColorUtil.hexToColor(
                                          appConfigNotifier
                                              .appConfig.color.colorAccent,
                                        );
                                        _linearListIconColor = kInactiveColor;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: _isLinearList
                              ? buildLinearList(snapshot.data.data.jsonArray)
                              : buildGridList(snapshot.data.data.jsonArray),
                        ),
                      ),
                    ],
                  );
                }
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
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildGridList(List<Shop> list) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => VendorDetailsPage(
                  shopId: list[index].id.toString(),
                ),
              ),
            )
                .then((value) {
              if (this.mounted) {
                this.setState(() {
                  loadShops = NetworkHelper.on().getFollowedShops(
                    context,
                  );
                });
              }
            });
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    list[index].cover,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildGridItemBody(list[index]),
              ),
            ),
          ),
        );
      },
      scrollDirection: Axis.vertical,
    );
  }

  Widget buildGridItemBody(Shop item) {
    double shopLatitude;
    double shopLongitude;

    if (item.latitude != null) {
      try {
        shopLatitude = double.parse(item.latitude);
      } catch (e) {
        // Do nothing for now
      }
    }

    if (item.longitude != null) {
      try {
        shopLongitude = double.parse(item.longitude);
      } catch (e) {
        // Do nothing for now
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFB9130),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            child: Text(
              "${item.openingStatus ? getString('open') : getString('closed')}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          item.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          item.address,
          style: TextStyle(
            color: Color(0xFFD9B6FA),
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RatingBarIndicator(
              rating: item.star,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 10.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
            if (appConfigNotifier.currentLocation != null &&
                shopLatitude != null &&
                shopLongitude != null)
              Text(
                "${LocationUtil.calculateDistanceInKM(
                  appConfigNotifier.currentLocation.latitude,
                  appConfigNotifier.currentLocation.longitude,
                  shopLatitude,
                  shopLongitude,
                ).toStringAsFixed(1)} ${getString('km')}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ],
    );
  }

  Widget buildLinearList(List<Shop> list) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => VendorDetailsPage(
                  shopId: list[index].id.toString(),
                ),
              ),
            )
                .then((value) {
              if (this.mounted) {
                this.setState(() {
                  loadShops = NetworkHelper.on().getFollowedShops(
                    context,
                  );
                });
              }
            });
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    list[index].cover,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildLinearItemBody(list[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLinearItemBody(Shop item) {
    double shopLatitude;
    double shopLongitude;

    if (item.latitude != null) {
      try {
        shopLatitude = double.parse(item.latitude);
      } catch (e) {
        // Do nothing for now
      }
    }

    if (item.longitude != null) {
      try {
        shopLongitude = double.parse(item.longitude);
      } catch (e) {
        // Do nothing for now
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFB9130),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            child: Text(
              "${item.openingStatus ? getString('open') : getString('closed')}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          item.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          item.address,
          style: TextStyle(
            color: Color(0xFFD9B6FA),
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RatingBarIndicator(
              rating: item.star,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 10.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
            if (appConfigNotifier.currentLocation != null &&
                shopLatitude != null &&
                shopLongitude != null)
              Text(
                "${LocationUtil.calculateDistanceInKM(
                  appConfigNotifier.currentLocation.latitude,
                  appConfigNotifier.currentLocation.longitude,
                  shopLatitude,
                  shopLongitude,
                ).toStringAsFixed(1)} ${getString('km')}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ],
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
