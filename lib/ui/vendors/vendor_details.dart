import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/shop.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/plain_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_non_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_shop_response.dart';
import 'package:azzoa_grocery/data/remote/response/wish_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/container/products/products.dart';
import 'package:azzoa_grocery/ui/product/details/product_details.dart';
import 'package:azzoa_grocery/ui/product/review/allreviews/all_reviews.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:azzoa_grocery/util/lib/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorDetailsPage extends StatefulWidget {
  final String shopId;

  VendorDetailsPage({@required this.shopId});

  @override
  _VendorDetailsPageState createState() => _VendorDetailsPageState();
}

const kExpandedHeight = 200.0;

class _VendorDetailsPageState extends State<VendorDetailsPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isListEmpty = false;

  TabController _tabController;
  ScrollController _scrollController;

  Future<ProductNonPaginatedListResponse> loadFeaturedProducts;
  Future<ProductNonPaginatedListResponse> loadPopularProducts;
  Future<ProductNonPaginatedListResponse> loadAllProducts;
  Future<String> _loadCurrency;
  Future<SingleShopResponse> _loadShop;

  GoogleMapController mapController;
  AppConfigNotifier appConfigNotifier;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  AppThemeAndLanguage themeAndLanguageNotifier;

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

    loadFeaturedProducts = NetworkHelper.on().getNonPaginatedProducts(
      context,
      limit: 4.toString(),
      tag: "featured",
      shopId: widget.shopId,
    );

    loadPopularProducts = NetworkHelper.on().getNonPaginatedProducts(
      context,
      limit: 4.toString(),
      tag: "popular",
      shopId: widget.shopId,
    );

    loadAllProducts = NetworkHelper.on().getNonPaginatedProducts(
      context,
      limit: 4.toString(),
      shopId: widget.shopId,
    );

    _loadCurrency = SharedPrefUtil.getString(kKeyCurrency);

    _loadShop = NetworkHelper.on().getSingleShop(
      context,
      widget.shopId,
    );

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _scrollController = ScrollController()..addListener(() => setState(() {}));

    super.initState();
  }

  bool get _showTitle {
    return _scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCommonBackgroundColor,
      child: FutureBuilder(
        future: _loadShop,
        builder: (context, AsyncSnapshot<SingleShopResponse> snapshot) {
          if (snapshot.hasData) {
            Shop item = snapshot.data.data.jsonObject;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                systemNavigationBarColor: kCommonBackgroundColor,
                systemNavigationBarIconBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.dark,
              ),
              child: Scaffold(
                backgroundColor: kCommonBackgroundColor,
                body: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        title: _showTitle
                            ? Text(
                                item.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                        elevation: 0.0,
                        backgroundColor: ColorUtil.hexToColor(
                          appConfigNotifier.appConfig.color.colorAccent,
                        ),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        expandedHeight: kExpandedHeight,
                        floating: false,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    item.cover,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFF000DFF).withOpacity(0.8),
                                          Color(0xFF6B73FF).withOpacity(0.3191),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        item.address,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        RatingBarIndicator(
                                          rating: item.star,
                                          direction: Axis.horizontal,
                                          itemCount: 5,
                                          itemSize: 16.0,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8.0,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return AllReviewsPage(
                                                    reviewableType: "shop",
                                                    reviewableId:
                                                        item.id.toString(),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Text(
                                            getString('see_all'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: InkWell(
                                        onTap: () {
                                          item.isFollowing
                                              ? _unfollowShop()
                                              : _followShop();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF09D2CA),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 24.0,
                                          ),
                                          child: Text(
                                            item.isFollowing
                                                ? getString('unfollow')
                                                : getString('follow'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.0,
                                            ),
                                          ),
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
                    ];
                  },
                  body: FutureBuilder(
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
                                item,
                                currency: snapshot.data,
                              );
                      } else {
                        return isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : buildBody(item);
                      }
                    },
                  ),
                ),
              ),
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
      ),
    );
  }

  Widget buildBody(Shop item, {String currency}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: 32.0,
            right: 32.0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: Card(
            elevation: 0.5,
            child: TabBar(
              labelPadding: const EdgeInsets.all(4.0),
              isScrollable: false,
              indicatorColor: Colors.transparent,
              labelColor: ColorUtil.hexToColor(
                appConfigNotifier.appConfig.color.colorAccent,
              ),
              unselectedLabelColor: Colors.black,
              controller: _tabController,
              labelStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(text: getString('all_product')),
                Tab(text: getString('about')),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              buildAllProductsBody(
                currency,
                item,
              ),
              buildAboutBody(
                currency,
                item,
              ),
            ],
          ),
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

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ToastUtil.show('${getString('could_not_launch')} $url');
    }
  }

  Widget buildAllProductsBody(String currency, Shop item) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildFeaturedProductList(currency),
            buildPopularProductList(currency),
            buildAllProductList(currency),
          ],
        ),
      ),
    );
  }

  Widget buildAboutBody(String currency, Shop item) {
    bool isParsed;
    double latitude, longitude;
    LatLng shopLatLng;

    try {
      latitude = double.parse(item.latitude);
      longitude = double.parse(item.longitude);
      shopLatLng = LatLng(
        latitude,
        longitude,
      );
      isParsed = true;
    } catch (e) {
      isParsed = false;
    }

    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              WebUtil.removeHtmlTags(stringWithHtmlTags: item.details),
              style: TextStyle(
                color: kSecondaryTextColor,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.justify,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ).withOpacity(0.7),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: Text(
                      "${item.address}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            if (isParsed)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: shopLatLng,
                      zoom: 13.0,
                    ),
                    markers: [
                      Marker(
                        markerId: MarkerId(item.name),
                        position: LatLng(latitude, longitude),
                        infoWindow: InfoWindow(
                          title: item.name,
                          snippet: item.address,
                        ),
                      )
                    ].toSet(),
                  ),
                ),
              ),
            buildButton(
              onPressCallback: () {
                if (item.email != null && item.email.isNotEmpty) {
                  _launchUrl('mailto:<${item.email}>');
                }
              },
              backgroundColor: ColorUtil.hexToColor(
                appConfigNotifier.appConfig.color.colorAccent,
              ),
              title: getString('contact_us'),
            ),
          ],
        ),
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
                getString('vendor_details_see_more'),
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

  Widget buildAllProductList(String currency) {
    return FutureBuilder(
      future: loadAllProducts,
      builder:
          (context, AsyncSnapshot<ProductNonPaginatedListResponse> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200 &&
            snapshot.data.data.jsonArray.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildHeader(
                  getString('vendor_details_all_products'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(
                          shopId: widget.shopId,
                        ),
                      ),
                    );
                  },
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
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
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
          return Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildHeader(
                  getString('homepage_featured_products'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(
                          pageTag: "Featured",
                          shopId: widget.shopId,
                        ),
                      ),
                    );
                  },
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
            ),
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

  Widget buildPopularProductList(String currency) {
    return FutureBuilder(
      future: loadPopularProducts,
      builder:
          (context, AsyncSnapshot<ProductNonPaginatedListResponse> snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200 &&
            snapshot.data.data.jsonArray.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildHeader(
                  getString('popular_products'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(
                          pageTag: "Popular",
                          shopId: widget.shopId,
                        ),
                      ),
                    );
                  },
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
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
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

  void _followShop() async {
    setState(() {
      isLoading = true;
    });

    try {
      PlainResponse response = await NetworkHelper.on().followShop(
        context,
        widget.shopId,
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        ToastUtil.show(
          getString('follow_successful'),
        );

        if (this.mounted) {
          this.setState(() {
            _loadShop = NetworkHelper.on().getSingleShop(
              context,
              widget.shopId,
            );
          });
        }
      } else {
        ToastUtil.show(
          getString('follow_unsuccessful'),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('follow_unsuccessful'),
        );
      }
    }
  }

  void _unfollowShop() async {
    setState(() {
      isLoading = true;
    });

    try {
      PlainResponse response = await NetworkHelper.on().unfollowShop(
        context,
        widget.shopId,
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        ToastUtil.show(
          getString('unfollow_successful'),
        );

        if (this.mounted) {
          this.setState(() {
            _loadShop = NetworkHelper.on().getSingleShop(
              context,
              widget.shopId,
            );
          });
        }
      } else {
        ToastUtil.show(
          getString('unfollow_unsuccessful'),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('unfollow_unsuccessful'),
        );
      }
    }
  }
}
