import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/category.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:azzoa_grocery/data/remote/response/category_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/shop_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/address/add/add_new_address.dart';
import 'package:azzoa_grocery/ui/vendors/nearby/nearby_shops.dart';
import 'package:azzoa_grocery/ui/vendors/vendor_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/location.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class AllVendorsPage extends StatefulWidget {
  final String pageTag;

  AllVendorsPage({
    this.pageTag,
  });

  @override
  _AllVendorsPageState createState() => _AllVendorsPageState();
}

class _AllVendorsPageState extends State<AllVendorsPage> {
  bool isLoading = false;
  bool isListEmpty = false;
  bool _isLinearList = false;
  TextEditingController _searchController;
  Color _gridListIconColor = kAccentColor;
  Color _linearListIconColor = kInactiveColor;

  int categoryId;

  Future<ShopListResponse> loadShops;

  AppConfigNotifier appConfigNotifier;
  List<Category> categoryList;

  Future<void> _getCategories({
    bool loadNeeded = false,
  }) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      CategoryListResponse response =
          await NetworkHelper.on().getShopCategories(
        context,
        limit: "20",
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        categoryList.clear();
        categoryList.addAll(response.data.jsonArray);

        if (this.mounted && loadNeeded) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        if (this.mounted && loadNeeded) {
          setState(() {
            isLoading = false;
          });
        }

        ToastUtil.show(
          getString('category_list_loading_failure'),
        );
      }
    } catch (e) {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = false;
        });
      }

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('category_list_loading_failure'),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    categoryList = [];
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
    loadShops = NetworkHelper.on().getShops(
      context,
      tag: widget.pageTag,
      categoryId: categoryId != null ? categoryId.toString() : null,
    );
    this._getCategories();

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
            getString('vendors_toolbar_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.all(18.0),
              child: GestureDetector(
                child: Image.asset(
                  "images/ic_locate.png",
                  fit: BoxFit.cover,
                  height: 18.0,
                  color: kInactiveColor,
                ),
                onTap: () {
                  showVendorBottomSheet(context);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 14.0, bottom: 14.0, right: 16.0),
              child: GestureDetector(
                child: Image.asset(
                  "images/ic_filter.png",
                  fit: BoxFit.cover,
                  height: 20.0,
                  color: kInactiveColor,
                ),
                onTap: () {
                  showFilterBottomSheet(context);
                },
              ),
            ),
          ],
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

  Future showFilterBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      backgroundColor: kCommonBackgroundColor,
      enableDrag: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return buildFilterBottomSheet(setState);
          },
        );
      },
    );
  }

  Widget buildFilterBottomSheet(setState) {
    return SingleChildScrollView(
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getString('filter'),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          categoryId = null;
                        });
                      },
                      child: Text(
                        getString('clear'),
                        style: TextStyle(
                          color: Color(0xFFFE408E),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (categoryList.isNotEmpty)
                  buildCategorySectionInFilter(
                    setState,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: buildButton(
                    onPressCallback: () {
                      Navigator.pop(context);
                      if (this.mounted) {
                        this.setState(() {
                          loadShops = NetworkHelper.on().getShops(
                            context,
                            tag: widget.pageTag,
                            categoryId: categoryId != null
                                ? categoryId.toString()
                                : null,
                          );
                        });
                      }
                    },
                    backgroundColor: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ),
                    title: getString('apply_filter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategorySectionInFilter(setState) {
    List<Widget> widgetList = [];

    categoryList.forEach((element) {
      widgetList.add(
        CheckboxListTile(
          dense: true,
          selected: categoryId == element.id,
          title: Text(element.name),
          value: categoryId == element.id,
          onChanged: (bool value) {
            setState(() {
              categoryId = value ? element.id : null;
            });
          },
          secondary: buildLeadingCircle(),
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildHeaderForFilter(getString('category')),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              children: widgetList,
            ),
          ),
        ],
      ),
    );
  }

  Container buildLeadingCircle() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF979797),
      ),
    );
  }

  Widget buildHeaderForFilter(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black.withOpacity(0.5),
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return SizedBox(
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
    );
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

  Future showVendorBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      backgroundColor: Colors.white,
      enableDrag: true,
      context: context,
      builder: (context) {
        return buildBottomSheet();
      },
    );
  }

  Wrap buildBottomSheet() {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                child: FlatButton.icon(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: Color(0xFFFF2C5D).withOpacity(.08),
                  icon: Icon(
                    Icons.add,
                    color: Color(0xFFDB0133),
                    size: 20.0,
                  ),
                  label: Text(
                    getString('vendors_add_new_address'),
                    style: TextStyle(
                      color: Color(0xFFDB0133),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return AddNewAddressPage(
                          pageTag: "Shipping",
                        );
                      }),
                    );
                  },
                ),
                width: double.infinity,
              ),
              SizedBox(
                height: 24.0,
              ),
              SizedBox(
                child: FlatButton.icon(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: Color(0xFF7101E3).withOpacity(.08),
                  icon: Icon(
                    Icons.location_on,
                    color: Color(0xFF5F00C1),
                    size: 20.0,
                  ),
                  label: Text(
                    getString('vendors_current_location'),
                    style: TextStyle(
                      color: Color(0xFF5F00C1),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    visitNearbyShops();
                  },
                ),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ],
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
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: Card(
            elevation: 0.0,
            child: TextFormField(
              textInputAction: TextInputAction.search,
              onChanged: (String value) {
                if (value.isEmpty && this.mounted) {
                  this.setState(() {
                    loadShops = NetworkHelper.on().getShops(
                      context,
                      tag: widget.pageTag,
                      categoryId:
                          categoryId != null ? categoryId.toString() : null,
                    );
                  });
                }
              },
              onFieldSubmitted: (String value) {
                if (this.mounted) {
                  this.setState(() {
                    loadShops = NetworkHelper.on().getShops(
                      context,
                      tag: widget.pageTag,
                      keyword: value,
                      categoryId:
                          categoryId != null ? categoryId.toString() : null,
                    );
                  });
                }
              },
              obscureText: false,
              style: TextStyle(
                color: kSecondaryTextColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: kSecondaryTextColor,
                ),
                hintText: getString('vendors_search'),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF40BFFF),
                ),
              ),
              controller: _searchController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
            ),
          ),
        ),
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
                              "${widget.pageTag != null ? (widget.pageTag + kSpaceString) : kDefaultString}Vendors",
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VendorDetailsPage(
                  shopId: list[index].id.toString(),
                ),
              ),
            );
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VendorDetailsPage(
                  shopId: list[index].id.toString(),
                ),
              ),
            );
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
