import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/address.dart';
import 'package:azzoa_grocery/data/remote/model/cart.dart';
import 'package:azzoa_grocery/data/remote/model/cart_item.dart';
import 'package:azzoa_grocery/data/remote/model/payment_method.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/model/shipping_method.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_product_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/checkout/payment/payment.dart';
import 'package:azzoa_grocery/ui/product/details/product_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CheckOutSummaryPage extends StatefulWidget {
  final Address shippingAddress;
  final Address billingAddress;
  final ShippingMethod shippingMethod;
  final PaymentMethod paymentMethod;

  CheckOutSummaryPage({
    @required this.shippingAddress,
    @required this.billingAddress,
    @required this.shippingMethod,
    @required this.paymentMethod,
  });

  @override
  _CheckOutSummaryPageState createState() => _CheckOutSummaryPageState();
}

class _CheckOutSummaryPageState extends State<CheckOutSummaryPage> {
  bool isLoading = false;
  TextEditingController _voucherCodeController;

  Future<CartResponse> _loadMyCart;

  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
    print("I am at checkout summary page - didChangeDependencies");
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('checkout_summary_title'),
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
      future: _loadMyCart,
      builder: (context, AsyncSnapshot<CartResponse> snapshot) {
        if (snapshot.hasData) {
          Cart cart = snapshot.data.data.jsonObject;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      buildOrderList(cart),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: buildAddress(
                          getString('shipping'),
                          widget.shippingAddress,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: buildAddress(
                          getString('billing'),
                          widget.billingAddress,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: buildShippingMethod(
                          widget.shippingMethod,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: buildPaymentMethod(
                          widget.paymentMethod,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48.0,
                        vertical: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: Colors.white,
                      child: Text(
                        getString('checkout_summary_back'),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    RaisedButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48.0,
                        vertical: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      onPressed: () {
                        _pay();
                      },
                      color: ColorUtil.hexToColor(
                        appConfigNotifier.appConfig.color.colorAccent,
                      ),
                      child: Text(
                        getString('checkout_summary_pay'),
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

  Widget buildAddress(String tag, Address item) {
    String subtitle = kDefaultString;

    if (item.streetAddress_2 != null) {
      if (subtitle.isNotEmpty) {
        subtitle += ", ";
      }

      subtitle += item.streetAddress_2;
    }

    if (item.city != null) {
      if (subtitle.isNotEmpty) {
        subtitle += ", ";
      }

      subtitle += item.city;
    }

    if (item.state != null) {
      if (subtitle.isNotEmpty) {
        subtitle += ", ";
      }

      subtitle += item.state;
    }

    if (item.phone != null) {
      if (subtitle.isNotEmpty) {
        subtitle += ", ";
      }

      subtitle += item.phone;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "$tag ${getString('address')}",
            style: TextStyle(
              color: Color(0xFF282828),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 4.0,
            ),
            child: Text(
              item.streetAddress_1,
              style: TextStyle(
                color: Color(0xFF414B5A),
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Color(0xFF414B5A),
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget buildShippingMethod(ShippingMethod item) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            getString('checkout_summary_shipping_method'),
            style: TextStyle(
              color: Color(0xFF282828),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 4.0,
            ),
            child: Text(
              item.name,
              style: TextStyle(
                color: Color(0xFF414B5A),
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            item.description,
            style: TextStyle(
              color: Color(0xFF414B5A),
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget buildPaymentMethod(PaymentMethod item) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            getString('checkout_summary_payment_method'),
            style: TextStyle(
              color: Color(0xFF282828),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 4.0,
            ),
            child: Text(
              item.name,
              style: TextStyle(
                color: Color(0xFF414B5A),
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            item.description,
            style: TextStyle(
              color: Color(0xFF414B5A),
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Padding buildCostSection(
    String title,
    String subtitle, {
    bool isRed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
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
          Text(
            subtitle,
            style: TextStyle(
              color: isRed ? kRedTextColor : Colors.black.withOpacity(0.5),
              fontSize: isRed ? 18.0 : 14.0,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget buildOrderList(Cart cart) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 20.0,
                ),
                children: <Widget>[
                  ListView.separated(
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
                        builder: (
                          context,
                          AsyncSnapshot<SingleProductResponse> snapshot,
                        ) {
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
                  ),
                ],
                title: Text(
                  getString('checkout_summary_order_list'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            buildCostSection(
              getString('cart_subtotal'),
              "${cart.netTotal} ${cart.currencyCode}",
            ),
            buildCostSection(
              getString('cart_tax'),
              "${cart.taxTotal} ${cart.currencyCode}",
            ),
            buildCostSection(
              getString('cart_discount'),
              "${cart.couponDiscount} ${cart.currencyCode}",
            ),
            buildCostSection(
              getString('total'),
              "${cart.grossTotal} ${cart.currencyCode}",
              isRed: true,
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
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
            width: 50,
            height: 50,
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
                    color: Color(0xFF282828),
                    fontSize: 12.0,
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
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  void _pay() async {
    setState(() {
      isLoading = true;
    });

    try {
      BaseResponse response = await NetworkHelper.on().placeOrder(
        context,
        widget.paymentMethod.id,
        widget.shippingMethod.id,
        widget.shippingAddress.id,
        widget.billingAddress.id,
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200 &&
          response.message != null &&
          response.message.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return PaymentPage(
              url: response.message,
            );
          }),
        ).then(
          (value) {
            if (value != null && value is bool) {
              if (value) {
                Navigator.of(context).pop(value);
              } else {
                ToastUtil.show(getString('checkout_summary_payment_error'));
              }
            }
          },
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('checkout_summary_place_order_error'),
        );
      }
    }
  }
}
