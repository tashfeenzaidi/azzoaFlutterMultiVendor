import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/cart.dart';
import 'package:azzoa_grocery/data/remote/model/cart_item.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_product_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/checkout/primary/checkout.dart';
import 'package:azzoa_grocery/ui/container/home/homepage.dart';
import 'package:azzoa_grocery/ui/container/home/homepage_content.dart';
import 'package:azzoa_grocery/ui/product/details/product_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  final HomePageState root;

  CartPage({@required this.root});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;
  TextEditingController _voucherCodeController;

  Future<CartResponse> _loadMyCart;
  AppConfigNotifier appConfigNotifier;
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
    print("I am at cart page - didChangeDependencies");
    _loadMyCart = NetworkHelper.on().getCart(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _voucherCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _voucherCodeController.dispose();
    super.dispose();
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
            getString('cart_toolbar_title'),
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

  Widget buildEmptyPlaceholder() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Container(
                    width: 170.0,
                    height: 170.0,
                    padding: const EdgeInsets.all(55.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Image.asset(
                      "images/ic_wishlist_empty_placeholder.png",
                      fit: BoxFit.cover,
                      height: 50.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  getString('cart_empty_title'),
                  style: TextStyle(
                    color: kRegularTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  getString('cart_empty_subtitle'),
                  style: TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          buildButton(
            onPressCallback: () {
              if (widget.root.mounted) {
                widget.root.setState(() {
                  widget.root.selectedBottomBarIndex = 0;
                  widget.root.body = HomeContentPage();
                });
              }
            },
            backgroundColor: ColorUtil.hexToColor(
              appConfigNotifier.appConfig.color.colorAccent,
            ),
            title: getString('cart_empty_button_text'),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return FutureBuilder(
      future: _loadMyCart,
      builder: (context, AsyncSnapshot<CartResponse> snapshot) {
        if (snapshot.hasData) {
          Cart cart = snapshot.data.data.jsonObject;

          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            themeAndLanguageNotifier.setCartItemCount(cart.items.length);
          });

          if (cart.items.isEmpty) {
            return buildEmptyPlaceholder();
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: buildLinearList(cart),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  buildCostSection(
                    getString('cart_subtotal'),
                    "${cart.netTotal} ${cart.currencyCode}",
                  ),
                  buildCostSection(
                    getString('cart_tax'),
                    "${cart.taxTotal} ${cart.currencyCode}",
                  ),
                  (cart.couponCode != null)
                      ? buildCostSection(
                          getString('cart_discount'),
                          "${cart.couponDiscount} ${cart.currencyCode}",
                          isDiscount: true,
                        )
                      : Card(
                          margin: const EdgeInsets.only(
                            top: 16.0,
                            left: 64.0,
                            right: 24.0,
                          ),
                          color: Colors.white,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: TextFormField(
                                    obscureText: false,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      hintText:
                                          getString('cart_enter_voucher_code'),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    controller: _voucherCodeController,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 16.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    _addCouponCodeToCart();
                                  },
                                  child: Text(
                                    getString('cart_apply').toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                  SizedBox(
                    height: 32.0,
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25.0),
                      ),
                    ),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  getString('cart_total'),
                                  style: TextStyle(
                                    color: Color(0xFF282828),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  "${cart.grossTotal} ${cart.currencyCode}",
                                  style: TextStyle(
                                    color: kRedTextColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            FlatButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              onPressed: () async {
                                String currencyCode =
                                    await SharedPrefUtil.getString(
                                        kKeyCurrency);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CheckOutPage(
                                        currency: currencyCode,
                                      );
                                    },
                                  ),
                                ).then((value) {
                                  if (value != null && value is bool && value) {
                                    ToastUtil.show(
                                        getString('payment_successful'));

                                    if (this.mounted) {
                                      this.setState(() {
                                        _loadMyCart =
                                            NetworkHelper.on().getCart(context);
                                      });
                                    }
                                  }
                                });
                              },
                              color: ColorUtil.hexToColor(
                                appConfigNotifier.appConfig.color.buttonColor_2,
                              ),
                              child: Text(
                                getString('cart_checkout'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
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

  Padding buildCostSection(
    String title,
    String subtitle, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 64.0,
        right: 24.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isDiscount)
                InkWell(
                  onTap: () {
                    _removeCouponFromCart();
                  },
                  child: Text(
                    getString('remove'),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (isDiscount) SizedBox(width: 16.0),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
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

  Widget buildLinearList(Cart cart) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: cart.items.length,
      itemBuilder: (BuildContext context, int index) {
        return FutureBuilder(
          future: NetworkHelper.on().getSingleProduct(
            context,
            cart.items[index].productId.toString(),
          ),
          builder: (context, AsyncSnapshot<SingleProductResponse> snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data.status != null &&
                snapshot.data.status == 200 &&
                snapshot.data.data.jsonObject != null) {
              Product product = snapshot.data.data.jsonObject;

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
                    padding: const EdgeInsets.all(16.0),
                    child: buildLinearItemBody(
                      cart.items[index],
                      cart.currencyCode,
                      product,
                    ),
                  ),
                ),
              );
            }

            return SizedBox.shrink();
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 0.0,
        );
      },
    );
  }

  Widget buildLinearItemBody(CartItem item, String currency, Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productId: product.id.toString(),
              attributes: item.attrs,
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
              ),
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
                  product.title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  "${item.price}${currency != null ? (kSpaceString + currency) : kDefaultString}",
                  style: TextStyle(
                    color: Color(0xFFFA6400),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (item.quantity - 1 > 0) {
                              _updateCart(
                                item.id.toString(),
                                (item.quantity - 1).toString(),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 4.0,
                              right: 16.0,
                            ),
                            child: Text(
                              "-",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Text(
                          "${item.quantity}",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        InkWell(
                          onTap: () {
                            _updateCart(
                              item.id.toString(),
                              (item.quantity + 1).toString(),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              "+",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        showRemovingBottomSheet(
                          context,
                          item.id.toString(),
                        );
                      },
                      child: Icon(
                        Icons.delete,
                        size: 20.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  Widget buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
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
      ),
    );
  }

  Future showRemovingBottomSheet(BuildContext context, String itemId) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      backgroundColor: Colors.white,
      enableDrag: true,
      context: context,
      builder: (context) {
        return buildBottomSheet(itemId);
      },
    );
  }

  Wrap buildBottomSheet(String itemId) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF2C5D).withOpacity(0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.delete,
                      color: Color(0xFFFF2C5D),
                    ),
                  ),
                ),
                title: Text(
                  getString('cart_remove_an_item'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    getString('cart_are_you_sure'),
                    style: TextStyle(
                      color: Color(0xFF919191),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FlatButton(
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.transparent,
                    child: Text(
                      getString('cart_no'),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  FlatButton(
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _removeFromCart(itemId);
                    },
                    color: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ),
                    child: Text(
                      getString('cart_yes'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _removeFromCart(String itemId) async {
    try {
      CartResponse response = await NetworkHelper.on().removeFromCart(
        context,
        itemId,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        ToastUtil.show(getString('cart_removed_item'));

        if (this.mounted) {
          this.setState(() {
            _loadMyCart = Future.value(response);
          });
        }
      }
    } catch (e) {
      if (!(e is AppException)) {
        ToastUtil.show(
          getString('cart_remove_error'),
        );
      }
    }
  }

  void _updateCart(String itemId, String quantity) async {
    setState(() {
      isLoading = true;
    });

    try {
      CartResponse response =
          await NetworkHelper.on().updateCart(context, itemId, quantity);

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          this.setState(() {
            _loadMyCart = Future.value(response);
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('cart_update_error'),
        );
      }
    }
  }

  bool _validateUserData() {
    if (_voucherCodeController.text.trim().isEmpty) {
      ToastUtil.show(getString('please_fill_up_the_field'));
      return false;
    } else {
      return true;
    }
  }

  void _addCouponCodeToCart() async {
    if (_validateUserData()) {
      KeyboardUtil.hideKeyboard(context);

      setState(() {
        isLoading = true;
      });

      try {
        CartResponse response = await NetworkHelper.on().addCouponToCart(
          context,
          _voucherCodeController.text.trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (response != null &&
            response.status != null &&
            response.status == 200) {
          if (this.mounted) {
            this.setState(() {
              _loadMyCart = Future.value(response);
            });
          }
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        if (!(e is AppException)) {
          ToastUtil.show(
            getString('cart_apply_discount_error'),
          );
        }
      }
    }
  }

  void _removeCouponFromCart() async {
    setState(() {
      isLoading = true;
    });

    try {
      CartResponse response = await NetworkHelper.on().removeCouponFromCart(
        context,
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          this.setState(() {
            _loadMyCart = Future.value(response);
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('cart_remove_discount_error'),
        );
      }
    }
  }
}
