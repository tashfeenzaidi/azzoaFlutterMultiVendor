import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/order_details.dart';
import 'package:azzoa_grocery/data/remote/model/ordered_item.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:azzoa_grocery/data/remote/response/order_details_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_product_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/orders/successfuldeliver/successful_delivery.dart';
import 'package:azzoa_grocery/ui/product/details/product_details.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  final String orderStatus;

  OrderDetailsPage({
    @required this.orderId,
    this.orderStatus,
  });

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool isLoading = false;

  Future<OrderDetailsResponse> _loadOrderDetails;
  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    _loadOrderDetails = NetworkHelper.on().getOrderDetails(
      context,
      widget.orderId,
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            "${getString('order')} # ${widget.orderId}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            if (widget.orderStatus != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Text(
                        widget.orderStatus,
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
              ),
          ],
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
      future: _loadOrderDetails,
      builder: (context, AsyncSnapshot<OrderDetailsResponse> snapshot) {
        if (snapshot.hasData) {
          OrderDetails orderDetails = snapshot.data.data.jsonObject;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      buildOrderList(orderDetails),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: buildShippingMethod(orderDetails),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: buildButton(
                    onPressCallback: () {},
                    backgroundColor: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.buttonColor_2,
                    ),
                    title: getString('view_current_status'),
                  ),
                ),
              ),
              if (orderDetails.status == 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                  child: buildButton(
                    onPressCallback: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessfullyDeliveredPage(
                            orderDetails: orderDetails,
                          ),
                        ),
                      );
                    },
                    backgroundColor: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ),
                    title: getString('order_details_review_now'),
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

  Widget buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0),
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

  Widget buildShippingMethod(OrderDetails orderDetails) {
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
            getString('shipping_method'),
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
              orderDetails.shippingMethodName,
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
            "${orderDetails.shippingCharge} ${orderDetails.currencyCode}",
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

  Widget buildOrderList(OrderDetails orderDetails) {
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
                    itemCount: orderDetails.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: NetworkHelper.on().getSingleProduct(
                          context,
                          orderDetails.items[index].productId.toString(),
                        ),
                        builder: (context,
                            AsyncSnapshot<SingleProductResponse> snapshot) {
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
                                    orderDetails.items[index],
                                    orderDetails.currencyCode,
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
                  getString('item_list'),
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
              "${orderDetails.netTotal} ${orderDetails.currencyCode}",
            ),
            buildCostSection(
              getString('cart_tax'),
              "${orderDetails.taxTotal} ${orderDetails.currencyCode}",
            ),
            buildCostSection(
              getString('cart_discount'),
              "${orderDetails.discount} ${orderDetails.currencyCode}",
            ),
            buildCostSection(
              getString('total'),
              "${orderDetails.grossTotal} ${orderDetails.currencyCode}",
              isRed: true,
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget buildLinearItemBody(
      OrderedItem item, String currency, Product product) {
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
}
