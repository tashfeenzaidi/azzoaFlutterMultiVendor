import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/banner.dart';
import 'package:azzoa_grocery/data/remote/model/category.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:azzoa_grocery/data/remote/response/banner_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/category_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_non_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/shop_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/wish_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/container/categories/categories.dart';
import 'package:azzoa_grocery/ui/container/products/products.dart';
import 'package:azzoa_grocery/ui/container/vendors/all_vendors.dart';
import 'package:azzoa_grocery/ui/container/wishlist/wish_list.dart';
import 'package:azzoa_grocery/ui/notifications/notifications.dart';
import 'package:azzoa_grocery/ui/product/details/product_details.dart';
import 'package:azzoa_grocery/ui/vendors/vendor_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/location.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class HomeContentPage extends StatefulWidget {
  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  bool isLoading;
  bool isListEmpty = false;
  bool isGettingData = false;
  bool isSearching = false;
  bool hasError;

  int currentPage, lastPage;
  String error;
  List<Product> list = [];

  TextEditingController _searchController;
  ScrollController _scrollController;

  Future<CategoryListResponse> loadCategories;
  Future<ShopListResponse> loadShops;
  Future<ProductNonPaginatedListResponse> loadFeaturedProducts;
  Future<ProductNonPaginatedListResponse> loadSaleProducts;
  Future<String> _loadCurrency;
  Future<BannerListResponse> _loadBanners;
  AppConfigNotifier appConfigNotifier;
  AppThemeAndLanguage themeAndLanguageNotifier;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    isLoading = false;
    hasError = false;
    list = [];
    currentPage = 1;
    error = kDefaultString;
    super.initState();
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
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    themeAndLanguageNotifier = Provider.of<AppThemeAndLanguage>(
      context,
      listen: false,
    );
    loadCategories = NetworkHelper.on().getProductCategories(
      context,
      limit: 10.toString(),
      tag: "featured",
    );

    loadFeaturedProducts = NetworkHelper.on().getNonPaginatedProducts(
      context,
      limit: 6.toString(),
      tag: "featured",
    );

    loadSaleProducts = NetworkHelper.on().getNonPaginatedProducts(
      context,
      limit: 6.toString(),
      tag: "sale",
    );

    _loadCurrency = SharedPrefUtil.getString(kKeyCurrency);

    loadShops = NetworkHelper.on().getShops(
      context,
      limit: 10.toString(),
      tag: "popular",
    );

    _loadBanners = NetworkHelper.on().getBannerList(
      context,
    );

    _checkAndGetLocation();

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
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            appConfigNotifier.appConfig.name,
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
                  "images/ic_wish_list_app_bar.png",
                  fit: BoxFit.cover,
                  height: 16.0,
                  color: kInactiveColor,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WishListPage(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 17.0, bottom: 17.0, right: 18.0),
              child: GestureDetector(
                child: Image.asset(
                  "images/ic_notifications_small.png",
                  fit: BoxFit.cover,
                  height: 18.0,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: kCommonBackgroundColor,
        body: SafeArea(
          child: FutureBuilder(
            future: _loadCurrency,
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.isNotEmpty) {
                return isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : buildBody(
                        currency: snapshot.data,
                      );
              } else {
                return isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : buildBody();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
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
      ),
    );
  }

  Widget buildBody({String currency}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Card(
            elevation: 0.0,
            child: TextFormField(
              textInputAction: TextInputAction.search,
              onChanged: (String value) {
                if (this.mounted) {
                  this.setState(() {
                    isSearching = value.isNotEmpty;

                    if (!isSearching) {
                      list.clear();
                    }
                  });
                }
              },
              onFieldSubmitted: (String value) {
                isGettingData = true;
                this._getList(1, keyword: value);
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
                hintText: getString('homepage_search_hint'),
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
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: isSearching
                ? (hasError
                    ? buildErrorBody(error)
                    : (isListEmpty
                        ? buildEmptyPlaceholder()
                        : buildGridList(
                            currency,
                          )))
                : SingleChildScrollView(
                    child: FutureBuilder(
                      future: _loadBanners,
                      builder: (
                        context,
                        AsyncSnapshot<BannerListResponse> snapshot,
                      ) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data.status != null &&
                            snapshot.data.status == 200) {
                          List<PromoBanner> bannerList =
                              snapshot.data.data.jsonArray;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (bannerList.isNotEmpty)
                                buildBannerList(bannerList),
                              buildCategoryList(),
                              buildVendorList(),
                              buildFeaturedProductList(currency),
                              buildBigSaleList(currency),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildBannerList(List<PromoBanner> bannerList) {
    return CarouselSlider.builder(
      itemCount: bannerList.length,
      options: CarouselOptions(
        height: 200,
        aspectRatio: 16 / 9,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: false,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
      itemBuilder: (BuildContext context, int itemIndex) {
        return buildBanner(bannerList[itemIndex]);
      },
    );
  }

  List<Widget> buildRemainingBanners(List<PromoBanner> bannerList) {
    List<Widget> remainingBanners = [];

    bannerList.forEach(
      (element) {
        remainingBanners.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: buildBanner(element),
          ),
        );
      },
    );

    return remainingBanners;
  }

  Widget buildBanner(PromoBanner item) {
    return InkWell(
      onTap: () {
        if (item.shopId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VendorDetailsPage(
                shopId: item.shopId.toString(),
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsPage(
                bannerId: item.id.toString(),
              ),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Center(
            child: Image.network(
              item.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          item.subtitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (item.title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text(
                    getString('shop_now'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(String title, VoidCallback onPressCallback) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
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
        GestureDetector(
          onTap: onPressCallback,
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
                getString('homepage_see_more'),
                style: TextStyle(
                  color: ColorUtil.hexToColor(
                    appConfigNotifier.appConfig.color.colorAccent,
                  ),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildVendorItemBody(Shop item) {
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

  Widget buildVendorList() {
    return FutureBuilder(
      future: loadShops,
      builder: (context, AsyncSnapshot<ShopListResponse> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200 &&
            snapshot.data.data.jsonArray.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  bottom: 16.0,
                ),
                child: buildHeader(
                  getString('homepage_popular_vendors'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllVendorsPage(),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.data.jsonArray.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VendorDetailsPage(
                              shopId: snapshot.data.data.jsonArray[index].id
                                  .toString(),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0.0,
                        child: Container(
                          width: 180.0,
                          decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                snapshot.data.data.jsonArray[index].cover,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: buildVendorItemBody(
                              snapshot.data.data.jsonArray[index],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 12.0,
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget buildCategoryList() {
    return FutureBuilder(
      future: loadCategories,
      builder: (context, AsyncSnapshot<CategoryListResponse> snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 16.0,
                ),
                child: buildHeader(
                  getString('homepage_featured_categories'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoriesPage(),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.data.jsonArray.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductsPage(
                              categoryId: snapshot.data.data.jsonArray[index].id
                                  .toString(),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0.0,
                        child: Container(
                          width: 120.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 8.0,
                            ),
                            child: buildCategoryItemBody(
                              snapshot.data.data.jsonArray[index],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 12.0,
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget buildCategoryItemBody(Category item) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.network(
          item.image,
          fit: BoxFit.cover,
          height: 30.0,
        ),
        SizedBox(height: 12.0),
        Text(
          item.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildFeaturedProductList(String currency) {
    return FutureBuilder(
      future: loadFeaturedProducts,
      builder:
          (context, AsyncSnapshot<ProductNonPaginatedListResponse> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200 &&
            snapshot.data.data.jsonArray.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  bottom: 8.0,
                ),
                child: buildHeader(
                  getString('homepage_featured_products'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(),
                      ),
                    );
                  },
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                ),
                itemCount: snapshot.data.data.jsonArray.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Card(
                    margin: index % 2 == 0
                        ? EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            right: 8.0,
                          )
                        : EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            left: 8.0,
                          ),
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
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: buildProductItemBody(
                          snapshot.data.data.jsonArray[index],
                          currency,
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget buildProductItemBody(Product item, String currency) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productId: item.id.toString(),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  height: 100.0,
                  width: double.infinity,
                ),
              ),
              Positioned(
                bottom: 0,
                child: InkWell(
                  onTap: () {
                    _addToCart(
                      item.parentId != null
                          ? item.parentId.toString()
                          : item.id.toString(),
                    );
                  },
                  child: Image.asset(
                    "images/ic_add_to_cart_small.png",
                    fit: BoxFit.fitHeight,
                    height: 40.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    _addToWishList(
                      item.parentId != null
                          ? item.parentId.toString()
                          : item.id.toString(),
                    );
                  },
                  child: Image.asset(
                    "images/ic_wishlist_small.png",
                    fit: BoxFit.fitHeight,
                    height: 40.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: TextStyle(
                    color: kRegularTextColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  "${item.salePrice}${currency != null ? (kSpaceString + currency) : kDefaultString} / ${item.per} ${item.unit}",
                  style: TextStyle(
                    color: kRedTextColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.salePrice != item.generalPrice)
                  SizedBox(
                    height: 8.0,
                  ),
                if (item.salePrice != item.generalPrice)
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              "${item.generalPrice}${currency != null ? (kSpaceString + currency) : kDefaultString}",
                          style: TextStyle(
                            fontSize: 13.0,
                            color: kSecondaryTextColor,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        TextSpan(
                          text: kSpaceString,
                        ),
                        TextSpan(
                          text: '${item.priceOff}% ${getString('off')}',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildBigSaleList(String currency) {
    return FutureBuilder(
      future: loadSaleProducts,
      builder:
          (context, AsyncSnapshot<ProductNonPaginatedListResponse> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200 &&
            snapshot.data.data.jsonArray.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  bottom: 8.0,
                ),
                child: buildHeader(
                  getString('homepage_big_sale'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(pageTag: "Sale"),
                      ),
                    );
                  },
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                ),
                itemCount: snapshot.data.data.jsonArray.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Card(
                    margin: index % 2 == 0
                        ? EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            right: 8.0,
                          )
                        : EdgeInsets.only(
                            top: 8.0,
                            bottom: 8.0,
                            left: 8.0,
                          ),
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
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: buildProductItemBody(
                          snapshot.data.data.jsonArray[index],
                          currency,
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget buildErrorBody(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: kRegularTextColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildGridList(String currency) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (!isGettingData &&
            notification.metrics.pixels ==
                notification.metrics.maxScrollExtent) {
          if (currentPage < lastPage) {
            isGettingData = true;
            this._getList(
              currentPage + 1,
            );
          }
        }

        return false;
      },
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.75,
          crossAxisCount: 2,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Card(
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: buildGridItemBody(list[index], currency),
              ),
            ),
          );
        },
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget buildGridItemBody(Product item, String currency) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productId: item.id.toString(),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  height: 100.0,
                  width: double.infinity,
                ),
              ),
              Positioned(
                bottom: 0,
                child: InkWell(
                  onTap: () {
                    _addToCart(
                      item.parentId != null
                          ? item.parentId.toString()
                          : item.id.toString(),
                    );
                  },
                  child: Image.asset(
                    "images/ic_add_to_cart_small.png",
                    fit: BoxFit.fitHeight,
                    height: 40.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    _addToWishList(
                      item.parentId != null
                          ? item.parentId.toString()
                          : item.id.toString(),
                    );
                  },
                  child: Image.asset(
                    "images/ic_wishlist_small.png",
                    fit: BoxFit.fitHeight,
                    height: 40.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: TextStyle(
                    color: kRegularTextColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  "${item.salePrice}${currency != null ? (kSpaceString + currency) : kDefaultString} / ${item.per} ${item.unit}",
                  style: TextStyle(
                    color: kRedTextColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.salePrice != item.generalPrice)
                  SizedBox(
                    height: 8.0,
                  ),
                if (item.salePrice != item.generalPrice)
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              "${item.generalPrice}${currency != null ? (kSpaceString + currency) : kDefaultString}",
                          style: TextStyle(
                            fontSize: 13.0,
                            color: kSecondaryTextColor,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        TextSpan(
                          text: kSpaceString,
                        ),
                        TextSpan(
                          text: '${item.priceOff}% ${getString('off')}',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  void _addToCart(String productId) async {
    setState(() {
      isLoading = true;
    });

    try {
      CartResponse response = await NetworkHelper.on().addToCart(
        context,
        themeAndLanguageNotifier,
        productId,
        "1",
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        ToastUtil.show(
          getString('added_to_cart'),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('add_item_to_cart_error'),
        );
      }
    }
  }

  void _addToWishList(String productId) async {
    setState(() {
      isLoading = true;
    });

    try {
      WishListResponse response = await NetworkHelper.on().addToWishList(
        context,
        productId,
        "1",
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        ToastUtil.show(
          getString('added_to_wish_list'),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('add_item_to_wish_list_error'),
        );
      }
    }
  }

  Future<void> _getList(
    int page, {
    String keyword,
    bool loadNeeded = true,
  }) async {
    try {
      if (this.mounted) {
        setState(() {
          if (page == 1 && loadNeeded) {
            isLoading = true;
          }
        });
      }

      ProductPaginatedListResponse response =
          await NetworkHelper.on().getPaginatedProducts(
        context,
        page,
        limit: 20.toString(),
        keyword: keyword,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          setState(() {
            if (page == 1) {
              list.clear();
            }

            list.addAll(response.data.jsonObject.data);
            currentPage = response.data.jsonObject.currentPage;
            lastPage = response.data.jsonObject.lastPage;
            hasError = false;
            isListEmpty = list.isEmpty;

            if (loadNeeded) {
              isLoading = false;
            }
          });
        }

        isGettingData = false;

        if (page == 1) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              curve: Curves.linear,
              duration: Duration(milliseconds: 500),
            );
          }
        }
      } else {
        isGettingData = false;
        if (this.mounted) {
          setState(() {
            if (loadNeeded) {
              isLoading = false;
            }

            hasError = true;
          });
        }

        error = getString('could_not_load_list');
      }
    } catch (e) {
      isGettingData = false;
      setState(() {
        hasError = true;

        if (loadNeeded) {
          isLoading = false;
        }
      });

      if (!(e is AppException)) {
        error = getString('could_not_load_list');
      }
    }
  }
}
