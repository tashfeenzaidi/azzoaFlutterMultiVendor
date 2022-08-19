import 'dart:collection';
import 'dart:convert' as convert;

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/base/extensions.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/local/model/attribute_content.dart';
import 'package:azzoa_grocery/data/remote/model/attribute.dart';
import 'package:azzoa_grocery/data/remote/model/category.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/term.dart';
import 'package:azzoa_grocery/data/remote/response/attribute_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/category_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/wish_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/product/details/product_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ProductsPage extends StatefulWidget {
  final String pageTag;
  final String categoryId;
  final String shopId;
  final String bannerId;

  ProductsPage({
    this.pageTag,
    this.categoryId,
    this.shopId,
    this.bannerId,
  });

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final String kAttributeColor = "color";
  bool isLoading;
  bool isListEmpty = false;
  bool isGettingData = false;
  bool _isLinearList = false;
  bool hasError;

  int currentPage, lastPage;
  String error;
  int isShopOpen = 0, isFreeShipping = 0, isDiscounted = 0, categoryId;

  ScrollController _scrollController;
  TextEditingController _searchController;

  Color _gridListIconColor = kAccentColor;
  Color _linearListIconColor = kInactiveColor;

  List<Product> list;
  Future<String> _loadCurrency;

  AppConfigNotifier appConfigNotifier;

  HashMap<String, List<AttributeContent>> attributeMap;
  HashMap<String, int> selectionMap;
  List<Attribute> attributeList;
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
          await NetworkHelper.on().getProductCategories(
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

  Future<void> _getAttributes({
    bool loadNeeded = false,
  }) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      AttributeListResponse response =
          await NetworkHelper.on().getAttributeList(
        context,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        attributeList.clear();
        attributeList.addAll(response.data.jsonArray);

        attributeList.forEach((attribute) {
          attributeMap.putIfAbsent(attribute.name.toLowerCase(), () {
            List<Term> termList = attribute.terms;
            List<AttributeContent> contentList = [];

            for (int i = 0; i < termList.length; i++) {
              contentList.add(
                AttributeContent(
                  id: i + 1,
                  title: termList[i].name,
                  attributeSlug: attribute.slug,
                  attributeTitle: attribute.title,
                  attributeName: attribute.name,
                  term: termList[i],
                ),
              );
            }

            return contentList;
          });
        });

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
          getString('attribute_list_loading_failure'),
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
          getString('attribute_list_loading_failure'),
        );
      }
    }
  }

  Future<void> _getProductList(
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

      ProductPaginatedListResponse response;

      if (widget.bannerId == null) {
        HashMap<String, String> selectedAttributeMap =
            HashMap<String, String>();

        selectionMap.keys.forEach((attributeSlug) {
          selectedAttributeMap.putIfAbsent(
            attributeSlug,
            () => attributeMap[attributeSlug][selectionMap[attributeSlug]]
                .term
                .slug,
          );
        });

        String attributes;
        if (selectedAttributeMap.isNotEmpty) {
          attributes = convert.jsonEncode(selectedAttributeMap);
        }

        response = await NetworkHelper.on().getPaginatedProducts(
          context,
          page,
          shopId: widget.shopId,
          categoryId: widget.categoryId ??
              (categoryId != null ? categoryId.toString() : null),
          tag: widget.pageTag,
          limit: 20.toString(),
          attributes: attributes,
          keyword: keyword,
          discount: isDiscounted != null ? isDiscounted.toString() : null,
          freeShipping:
              isFreeShipping != null ? isFreeShipping.toString() : null,
          shopOpen: isShopOpen != null ? isShopOpen.toString() : null,
        );
      } else {
        response = await NetworkHelper.on().getBannerProducts(
          context,
          page,
          widget.bannerId,
          limit: 20.toString(),
        );
      }

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

    attributeList = [];
    categoryList = [];
    attributeMap = HashMap<String, List<AttributeContent>>();
    selectionMap = HashMap<String, int>();

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
    _gridListIconColor = ColorUtil.hexToColor(
      appConfigNotifier.appConfig.color.colorAccent,
    );
    isGettingData = true;
    this._getProductList(currentPage);
    this._getAttributes();
    this._getCategories();
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
        appBar: AppBar(
          brightness: Brightness.light,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            "${widget.pageTag != null ? (widget.pageTag + kSpaceString) : kDefaultString}Products",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
          actions: <Widget>[
            if (widget.bannerId == null)
              Padding(
                padding: EdgeInsets.all(16.0),
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
                        : (hasError
                            ? buildErrorBody(error)
                            : (isListEmpty
                                ? buildEmptyPlaceholder()
                                : buildProductList(
                                    currency: snapshot.data,
                                  )));
                  } else {
                    return isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : (hasError
                            ? buildErrorBody(error)
                            : (isListEmpty
                                ? buildEmptyPlaceholder()
                                : buildProductList()));
                  }
                },
              ),
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
            return buildBottomSheet(setState);
          },
        );
      },
    );
  }

  Widget buildBottomSheet(setState) {
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
                          isShopOpen = null;
                          isFreeShipping = null;
                          isDiscounted = null;
                          categoryId = null;
                          selectionMap.clear();
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
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      buildHeaderForFilter(getString('discount')),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              dense: true,
                              selected: isDiscounted == 1,
                              title: Text(getString('discounted')),
                              value: isDiscounted == 1,
                              onChanged: (bool value) {
                                setState(() {
                                  isDiscounted = value ? 1 : 0;
                                });
                              },
                              secondary: buildLeadingCircle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      buildHeaderForFilter(getString('delivery')),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              dense: true,
                              selected: isFreeShipping == 1,
                              title: Text(getString('free')),
                              value: isFreeShipping == 1,
                              onChanged: (bool value) {
                                setState(() {
                                  isFreeShipping = value ? 1 : 0;
                                });
                              },
                              secondary: buildLeadingCircle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      buildHeaderForFilter(getString('open_store')),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              dense: true,
                              selected: isShopOpen == 1,
                              title: Text(getString('open')),
                              value: isShopOpen == 1,
                              onChanged: (bool value) {
                                setState(() {
                                  isShopOpen = value ? 1 : 0;
                                });
                              },
                              secondary: buildLeadingCircle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (categoryList.isNotEmpty && widget.categoryId == null)
                  buildCategorySectionInFilter(
                    setState,
                  ),
                if (attributeList.isNotEmpty) buildAttributeSection(setState),
                /*Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: buildColorList(
                      getString('choose_color'),
                      attributeList,
                      setState,
                    ),
                  ),*/
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: buildButton(
                    onPressCallback: () {
                      Navigator.pop(context);
                      if (this.mounted) {
                        this.setState(() {
                          this._getProductList(1, loadNeeded: true);
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

  Widget buildAttributeSection(setState) {
    List<Widget> widgetList = [];

    attributeMap.keys.forEach(
      (key) {
        List<AttributeContent> contentList = attributeMap[key];

        widgetList.add(
          Padding(
            padding: attributeMap.keys.last == key
                ? const EdgeInsets.all(0.0)
                : const EdgeInsets.only(bottom: 24.0),
            child: key.toLowerCase() == "color"
                ? buildColorList(
                    key.toTitleCase(),
                    contentList,
                    setState,
                  )
                : buildAttributeList(
                    key.toTitleCase(),
                    contentList,
                    setState,
                  ),
          ),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetList,
      ),
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

  Widget buildAttributeList(
    String title,
    List<AttributeContent> list,
    setState,
  ) {
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
                setState(() {
                  selectionMap[item.attributeSlug] = i;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectionMap[item.attributeSlug] == i
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
          buildHeaderForFilter(title),
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

  Widget buildColorList(
    String title,
    List<AttributeContent> attributeList,
    setState,
  ) {
    final widgetItemList = <Widget>[];
    Widget finalWidget;

    if (attributeList.length > 0) {
      for (int i = 0; i < attributeList.length; i++) {
        AttributeContent item = attributeList[i];

        widgetItemList.add(
          Padding(
            padding: i != attributeList.length - 1
                ? const EdgeInsets.only(right: 8.0)
                : const EdgeInsets.all(0.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectionMap[item.attributeSlug] = i;
                });
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
                    child: selectionMap[item.attributeSlug] == i
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
          buildHeaderForFilter(title),
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

  Widget buildProductList({String currency}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.bannerId == null)
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
                  if (value.isEmpty) {
                    isGettingData = true;
                    this._getProductList(1, loadNeeded: false);
                  }
                },
                onFieldSubmitted: (String value) {
                  isGettingData = true;
                  this._getProductList(1, keyword: value, loadNeeded: false);
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
                  hintText: getString('featured_products_search'),
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
        Padding(
          padding: const EdgeInsets.only(
            right: 16.0,
            bottom: 16.0,
            left: 16.0,
          ),
          child: Row(
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
                      _linearListIconColor = ColorUtil.hexToColor(
                        appConfigNotifier.appConfig.color.colorAccent,
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
                      _gridListIconColor = ColorUtil.hexToColor(
                        appConfigNotifier.appConfig.color.colorAccent,
                      );
                      _linearListIconColor = kInactiveColor;
                    });
                  }
                },
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
                ? buildLinearList(currency)
                : buildGridList(currency),
          ),
        ),
      ],
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
            this._getProductList(
              currentPage + 1,
            );
          }
        }

        return false;
      },
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.72,
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

  Widget buildLinearList(String currency) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (!isGettingData &&
            notification.metrics.pixels ==
                notification.metrics.maxScrollExtent) {
          if (currentPage < lastPage) {
            isGettingData = true;
            this._getProductList(
              currentPage + 1,
            );
          }
        }

        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
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
                child: buildLinearItemBody(list[index], currency),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildLinearItemBody(Product item, String currency) {
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
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              item.image,
              fit: BoxFit.fitHeight,
              height: 100.0,
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
          ),
          SizedBox(
            width: 16.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
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
              SizedBox(
                height: 16.0,
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
}
