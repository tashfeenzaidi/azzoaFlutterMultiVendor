import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/local/service/database_service.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/wish_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/product/details/product_details.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class GlobalSearchPage extends StatefulWidget {
  @override
  _GlobalSearchPageState createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  bool isLoading;
  bool isListEmpty = false;
  bool isRecommendedListEmpty = false;
  bool isPopularListEmpty = false;
  bool isRecentListEmpty = false;
  bool isSearching = false;
  bool hasError;
  bool isGettingData = false;
  bool isGettingRecommendedData = false;

  int currentPage, lastPage;
  int recommendedCurrentPage = 1, recommendedLastPage;
  String error;
  List<Product> list = [];
  List<Product> recommendedProductList = [];
  List<Product> popularProductList = [];
  List<Product> recentViewProductList = [];

  TextEditingController _searchController;
  ScrollController _scrollController;
  ScrollController _recommendedScrollController;
  Future<String> _loadCurrency;
  AppConfigNotifier appConfigNotifier;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _recommendedScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _recommendedScrollController = ScrollController();
    isLoading = false;
    hasError = false;
    list = [];
    currentPage = 1;
    error = kDefaultString;
    super.initState();
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
    _loadCurrency = SharedPrefUtil.getString(kKeyCurrency);

    isGettingRecommendedData = true;
    this._getRecommendedProducts(recommendedCurrentPage, loadNeeded: true);
    this._getRecentProducts();
    this._getPopularProducts();

    super.didChangeDependencies();
  }

  Future<void> _getPopularProducts({bool loadNeeded = false}) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      ProductPaginatedListResponse response;

      response = await NetworkHelper.on().getPaginatedProducts(
        context,
        1,
        limit: 20.toString(),
        orderBy: kKeyViews,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          setState(() {
            popularProductList.clear();
            popularProductList.addAll(response.data.jsonObject.data);
            hasError = false;
            isPopularListEmpty = popularProductList.isEmpty;

            if (loadNeeded) {
              isLoading = false;
            }
          });
        }
      } else {
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

  Future<void> _getRecommendedProducts(
    int page, {
    bool loadNeeded = true,
  }) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      ProductPaginatedListResponse response;

      response = await NetworkHelper.on().getPaginatedProducts(
        context,
        page,
        limit: 20.toString(),
        orderBy: kKeyAverageRating,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          setState(() {
            if (page == 1) {
              recommendedProductList.clear();
            }

            recommendedProductList.addAll(response.data.jsonObject.data);
            recommendedCurrentPage = response.data.jsonObject.currentPage;
            recommendedLastPage = response.data.jsonObject.lastPage;
            hasError = false;
            isRecommendedListEmpty = recommendedProductList.isEmpty;

            if (loadNeeded) {
              isLoading = false;
            }
          });
        }

        isGettingRecommendedData = false;

        if (page == 1) {
          if (_recommendedScrollController.hasClients) {
            _recommendedScrollController.animateTo(
              0.0,
              curve: Curves.linear,
              duration: Duration(milliseconds: 500),
            );
          }
        }
      } else {
        isGettingRecommendedData = false;

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
      isGettingRecommendedData = false;
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

  Future<void> _getRecentProducts({
    bool loadNeeded = false,
  }) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      recentViewProductList.clear();
      recentViewProductList.addAll(await DatabaseService.on().getProducts());

      setState(() {
        hasError = false;
        isRecentListEmpty = recentViewProductList.isEmpty;

        if (loadNeeded) {
          isLoading = false;
        }
      });
    } catch (e) {
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

  Widget buildPopularProductList(String currency) {
    return Container(
      height: 100,
      child: isPopularListEmpty
          ? buildEmptyPlaceholder()
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.5,
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 10.0,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: popularProductList.length,
              itemBuilder: (BuildContext context, int index) {
                Product item = popularProductList[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(
                          productId: item.id.toString(),
                        ),
                      ),
                    ).then((value) => this._getRecentProducts());
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      child: Center(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: kRegularTextColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget buildRecentViewList(String currency) {
    return Container(
      height: 80,
      child: isRecentListEmpty
          ? buildEmptyPlaceholder()
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: recentViewProductList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                Product item = recentViewProductList[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(
                          productId: item.id.toString(),
                        ),
                      ),
                    ).then((value) => this._getRecentProducts());
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0.0,
                    child: Container(
                      width: 80.0,
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        item.image,
                        fit: BoxFit.contain,
                        height: 48.0,
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
                hintText: getString('search_hint'),
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
              top: 8.0,
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
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Text(
                          getString('popular'),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      buildPopularProductList(currency),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                          left: 8.0,
                          right: 8.0,
                          top: 16.0,
                        ),
                        child: Text(
                          getString('recent_view'),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      buildRecentViewList(currency),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                          left: 8.0,
                          right: 8.0,
                          top: 16.0,
                        ),
                        child: Text(
                          getString('recommendation'),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: isRecommendedListEmpty
                            ? buildEmptyPlaceholder()
                            : buildLinearListForRecommendedProduct(currency),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildLinearListForRecommendedProduct(String currency) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (!isGettingRecommendedData &&
            notification.metrics.pixels ==
                notification.metrics.maxScrollExtent) {
          if (recommendedCurrentPage < recommendedLastPage) {
            isGettingRecommendedData = true;
            this._getRecommendedProducts(
              recommendedCurrentPage + 1,
            );
          }
        }

        return false;
      },
      child: ListView.builder(
        controller: _recommendedScrollController,
        scrollDirection: Axis.vertical,
        itemCount: recommendedProductList.length,
        itemBuilder: (BuildContext context, int index) {
          Product item = recommendedProductList[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(
                    productId: item.id.toString(),
                  ),
                ),
              ).then((value) => this._getRecentProducts());
            },
            child: Card(
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
                  padding: const EdgeInsets.all(8.0),
                  child: buildLinearItemBodyForRecommendedProduct(
                    recommendedProductList[index],
                    currency,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildLinearItemBodyForRecommendedProduct(
    Product item,
    String currency,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            item.image,
            fit: BoxFit.fitHeight,
            height: 70.0,
          ),
        ),
        SizedBox(
          width: 16.0,
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                "${item.salePrice}${currency != null ? (kSpaceString + currency) : kDefaultString}",
                style: TextStyle(
                  color: kRedTextColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
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
            InkWell(
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
          ],
        ),
      ],
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
        ).then((value) => this._getRecentProducts());
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
