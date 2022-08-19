import 'dart:collection';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/local/model/attribute_content.dart';
import 'package:azzoa_grocery/data/local/service/database_service.dart';
import 'package:azzoa_grocery/data/remote/model/attribute.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/review.dart';
import 'package:azzoa_grocery/data/remote/model/term.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_non_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/review_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_product_response.dart';
import 'package:azzoa_grocery/data/remote/response/wish_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/container/products/products.dart';
import 'package:azzoa_grocery/ui/product/review/allreviews/all_reviews.dart';
import 'package:azzoa_grocery/ui/product/review/writereview/write_a_review.dart';
import 'package:azzoa_grocery/ui/vendors/vendor_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:azzoa_grocery/util/lib/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final Map<String, String> attributes;

  ProductDetailsPage({
    @required this.productId,
    this.attributes,
  });

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isLoading = false;
  bool isListEmpty = false;
  bool hasError = false;
  bool isVariantFetched = false;
  bool hasInserted = false;

  String error = kDefaultString;
  String productImageUrl = kDefaultString;
  String productPrice = kDefaultString;
  String productTitle = kDefaultString;
  String productDescription = kDefaultString;
  String productDeliveryTime = kDefaultString;

  Future<SingleProductResponse> _loadProduct;
  Future<String> _loadCurrency;

  HashMap<String, List<AttributeContent>> attributeMap;
  HashMap<String, int> selectionMap;

  AppConfigNotifier appConfigNotifier;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    attributeMap = HashMap<String, List<AttributeContent>>();
    selectionMap = HashMap<String, int>();

    super.initState();
  }

  Future<void> _getVariantProduct({
    bool loadNeeded = true,
  }) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      Map<String, String> attributes = Map();
      attributeMap.keys.forEach((key) {
        attributes[key] = attributeMap[key][selectionMap[key]].term.slug;
      });

      SingleProductResponse response =
          await NetworkHelper.on().getProductVariant(
        context,
        widget.productId,
        attributes,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        String currency = await SharedPrefUtil.getString(kKeyCurrency);
        Product item = response.data.jsonObject;
        isVariantFetched = true;

        if (this.mounted) {
          setState(() {
            hasError = false;
            productImageUrl = item.image;
            productPrice =
                "${item.salePrice}${currency != null ? (kSpaceString + currency) : kDefaultString} / ${item.per} ${item.unit}";
            productTitle = item.title;
            productDescription = item.content;
            productDeliveryTime =
                "${getString('delivery_time')} : ${item.deliveryTime}";

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

        error = getString('product_details_load_variant_error');
      }
    } catch (e) {
      setState(() {
        hasError = true;

        if (loadNeeded) {
          isLoading = false;
        }
      });

      if (!(e is AppException)) {
        error = getString('product_details_load_variant_error');
      }
    }
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

    _loadProduct = NetworkHelper.on().getSingleProduct(
      context,
      widget.productId,
    );

    _loadCurrency = SharedPrefUtil.getString(kKeyCurrency);

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
        backgroundColor: kCommonBackgroundColor,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            getString('product_details_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
        ),
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
        padding: const EdgeInsets.all(32.0),
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

  Widget buildBody({String currency}) {
    return FutureBuilder<SingleProductResponse>(
      future: _loadProduct,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200) {
          Product item = snapshot.data.data.jsonObject;

          if (!hasInserted) {
            hasInserted = true;
            DatabaseService.on().insertProduct(item);
          }

          if (item.type.toLowerCase() == "variable") {
            try {
              item.attrs.forEach((attribute) {
                attributeMap.putIfAbsent(attribute.name, () {
                  List<String> contentStringList = attribute.content;
                  List<Term> termList = attribute.terms;
                  List<AttributeContent> contentList = [];

                  for (int i = 0; i < contentStringList.length; i++) {
                    String contentTitle = contentStringList[i];
                    contentList.add(
                      AttributeContent(
                        id: i + 1,
                        title: contentTitle,
                        attributeSlug: attribute.name,
                        attributeTitle: attribute.title,
                        attributeName: attribute.name,
                        term: attribute.attributeId != null
                            ? termList[i]
                            : (Term()
                              ..data = contentTitle
                              ..slug = contentTitle),
                      ),
                    );
                  }

                  return contentList;
                });

                if (!selectionMap.containsKey(attribute.name)) {
                  _preparePredefinedAttributes(attribute);
                }
              });

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (!isVariantFetched) {
                  this._getVariantProduct();
                }
              });
            } catch (e) {
              if (e != null &&
                  e.toString() != null &&
                  e.toString().trim().isNotEmpty) {
                print(e);
              }
            }
          } else {
            productImageUrl = item.image;
            productPrice =
                "${item.salePrice}${currency != null ? (kSpaceString + currency) : kDefaultString} / ${item.per} ${item.unit}";
            productTitle = item.title;
            productDescription = item.content;
            productDeliveryTime =
                "${getString('delivery_time')} : ${item.deliveryTime}";
          }

          return hasError
              ? buildErrorBody(error)
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: buildMainBody(
                          item,
                          currency: currency,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            padding: const EdgeInsets.all(16.0),
                            onPressed: () {
                              _addToCart(widget.productId);
                            },
                            color: ColorUtil.hexToColor(
                              appConfigNotifier.appConfig.color.colorAccent,
                            ),
                            child: Text(
                              getString('product_details_add_to_cart'),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            padding: const EdgeInsets.all(16.0),
                            onPressed: () {
                              _addToWishList(widget.productId);
                            },
                            color: ColorUtil.hexToColor(
                              appConfigNotifier.appConfig.color.buttonColor_2,
                            ),
                            child: Text(
                              getString('product_details_add_to_wish_list'),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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

  void _preparePredefinedAttributes(Attribute attribute) {
    if (widget.attributes != null &&
        widget.attributes.containsKey(attribute.name)) {
      String predefinedValue = widget.attributes[attribute.name];

      for (int i = 0; i < attributeMap[attribute.name].length; i++) {
        AttributeContent currentContent = attributeMap[attribute.name][i];

        if (currentContent.title == predefinedValue) {
          selectionMap.putIfAbsent(attribute.name, () => i);
        }
      }
    } else {
      selectionMap.putIfAbsent(attribute.name, () => 0);
    }
  }

  Widget buildMainBody(Product item, {String currency}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Image.network(
          productImageUrl,
          height: 250,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      productPrice,
                      style: TextStyle(
                        color: kRedTextColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (item.shopId != null || item.shopId != -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorDetailsPage(
                              shopId: item.shopId.toString(),
                            ),
                          ),
                        );
                      } else {
                        ToastUtil.show(
                          getString('product_details_find_shop_error'),
                        );
                      }
                    },
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
                          getString('visit_store'),
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
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                productTitle,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 8.0,
              ),
              RatingBarIndicator(
                rating: item.star,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 20.0,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                unratedColor: Color(0xFFC4C9DA),
              ),
              SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  getString('description'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                WebUtil.removeHtmlTags(stringWithHtmlTags: productDescription),
                style: TextStyle(
                  color: kSecondaryTextColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.0),
              Container(
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
                    productDeliveryTime,
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
              if (item.type.toLowerCase() == "variable")
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 16.0,
                  ),
                  child: buildVariantSection(),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      getString('reviews'),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllReviewsPage(
                              reviewableId: item.id.toString(),
                              reviewableType: "product",
                            ),
                          ),
                        );
                      },
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
                            getString('see_more'),
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
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RatingBarIndicator(
                    rating: item.star,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemSize: 20.0,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    unratedColor: Color(0xFFC4C9DA),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "${item.star} / 5.0",
                    style: TextStyle(
                      color: kSecondaryTextColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              FutureBuilder(
                future: NetworkHelper.on().getReviews(
                  context,
                  1,
                  item.id.toString(),
                  "product",
                ),
                builder: (
                  context,
                  AsyncSnapshot<ReviewPaginatedListResponse> snapshot,
                ) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data.status != null &&
                      snapshot.data.status == 200 &&
                      snapshot.data.data.jsonObject.data.isNotEmpty) {
                    Review review = snapshot.data.data.jsonObject.data.first;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              backgroundImage: NetworkImage(
                                review.user.avatar,
                              ),
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4.0,
                                    ),
                                    child: Text(
                                      review.user.name,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                  RatingBarIndicator(
                                    rating: review.rating,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemSize: 18.0,
                                    itemPadding: EdgeInsets.zero,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    unratedColor: Color(0xFFC4C9DA),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12.0,
                            bottom: 16.0,
                          ),
                          child: Text(
                            review.content ?? kDefaultString,
                            style: TextStyle(
                              color: Color(0xFF9FA6BB),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () async {
                  await Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => WriteAReviewPage(
                        reviewableType: "product",
                        reviewableId: item.id.toString(),
                      ),
                    ),
                  )
                      .then((value) {
                    if (value != null &&
                        value is bool &&
                        value &&
                        this.mounted) {
                      this.setState(() {
                        _loadProduct = NetworkHelper.on().getSingleProduct(
                          context,
                          widget.productId,
                        );
                      });
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFB87538).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      getString('product_details_write_a_review'),
                      style: TextStyle(
                        color: Color(0xFFD06300),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: buildMayLikeProductsList(
                  currency,
                  item.categoryId.toString(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildHeaderForVariant(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildColorList(String title, List<AttributeContent> list) {
    final widgetItemList = <Widget>[];
    Widget finalWidget;

    if (list.length > 0) {
      for (int i = 0; i < list.length; i++) {
        AttributeContent item = list[i];

        widgetItemList.add(
          Padding(
            padding: i != list.length - 1
                ? const EdgeInsets.only(right: 8.0)
                : const EdgeInsets.all(0.0),
            child: InkWell(
              onTap: () {
                if (this.mounted) {
                  this.setState(() {
                    isVariantFetched = false;
                    selectionMap[item.attributeName] = i;
                  });
                }
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.hexToColor(item.term.data),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: selectionMap[item.attributeName] == i
                        ? Icon(
                            Icons.done,
                            color: item.title.toLowerCase() == "white"
                                ? Colors.black
                                : Colors.white,
                          )
                        : Container(
                            color: Colors.transparent,
                            width: 24.0,
                            height: 24.0,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      finalWidget = Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildHeaderForVariant(title),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: widgetItemList),
            ),
          ),
        ],
      );
    } else {
      finalWidget = SizedBox.shrink();
    }

    return finalWidget;
  }

  Widget buildVariantList(String title, List<AttributeContent> list) {
    final widgetItemList = <Widget>[];
    Widget finalWidget;

    if (list.length > 0) {
      for (int i = 0; i < list.length; i++) {
        AttributeContent item = list[i];

        widgetItemList.add(
          Padding(
            padding: i != list.length - 1
                ? const EdgeInsets.only(right: 8.0)
                : const EdgeInsets.all(0.0),
            child: InkWell(
              onTap: () {
                if (this.mounted) {
                  this.setState(() {
                    isVariantFetched = false;
                    selectionMap[item.attributeName] = i;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectionMap[item.attributeName] == i
                      ? ColorUtil.hexToColor(
                          appConfigNotifier.appConfig.color.colorAccent,
                        ).withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(6.0),
                  ),
                  border: Border.all(
                    color: Color(0xFFC4C9DA),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      finalWidget = Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildHeaderForVariant(title),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: widgetItemList),
            ),
          ),
        ],
      );
    } else {
      finalWidget = SizedBox.shrink();
    }

    return finalWidget;
  }

  Widget buildVariantSection() {
    final widgetList = <Widget>[];

    attributeMap.keys.forEach(
      (key) {
        List<AttributeContent> contentList = attributeMap[key];

        if (contentList.isNotEmpty)
          widgetList.add(
            Padding(
              padding: attributeMap.keys.last == key
                  ? const EdgeInsets.all(0.0)
                  : const EdgeInsets.only(bottom: 24.0),
              child: key == "color"
                  ? buildColorList(
                      "${getString('select')} ${contentList.first.attributeTitle}",
                      contentList,
                    )
                  : buildVariantList(
                      "${getString('select')} ${contentList.first.attributeTitle}",
                      contentList,
                    ),
            ),
          );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgetList,
    );
  }

  Widget buildMayLikeProductsList(String currency, String categoryId) {
    return FutureBuilder(
      future: NetworkHelper.on().getNonPaginatedProducts(
        context,
        limit: 10.toString(),
        categoryId: categoryId,
      ),
      builder: (
        context,
        AsyncSnapshot<ProductNonPaginatedListResponse> snapshot,
      ) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200 &&
            snapshot.data.data.jsonArray.isNotEmpty) {
          List<Product> list = [];
          list.addAll(
            snapshot.data.data.jsonArray.where((element) {
              return element.id.toString() != widget.productId;
            }),
          );

          return list.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildHeader(
                      getString('you_may_also_like'),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductsPage(
                              categoryId: categoryId,
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
                      itemCount: list.length,
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
                                list[index],
                                currency,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                )
              : SizedBox.shrink();
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget buildProductItemBody(Product item, String currency) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
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

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  void _addToCart(String productId) async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, String> attributes = Map();
      attributeMap.keys.forEach((key) {
        attributes[key] = attributeMap[key][selectionMap[key]].term.slug;
      });

      CartResponse response = await NetworkHelper.on().addToCart(
        context,
        themeAndLanguageNotifier,
        productId,
        "1",
        attributes: attributes,
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
      Map<String, String> attributes = Map();
      attributeMap.keys.forEach((key) {
        attributes[key] = attributeMap[key][selectionMap[key]].term.slug;
      });

      WishListResponse response = await NetworkHelper.on().addToWishList(
        context,
        productId,
        "1",
        attributes: attributes,
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
}
