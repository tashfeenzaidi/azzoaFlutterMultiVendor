import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/order_details.dart';
import 'package:azzoa_grocery/ui/product/review/writereview/write_a_review.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SuccessfullyDeliveredPage extends StatefulWidget {
  final OrderDetails orderDetails;

  SuccessfullyDeliveredPage({@required this.orderDetails});

  @override
  _SuccessfullyDeliveredPageState createState() =>
      _SuccessfullyDeliveredPageState();
}

class _SuccessfullyDeliveredPageState extends State<SuccessfullyDeliveredPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF02CC87),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kCommonBackgroundColor,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFC2E998), Color(0xFF02CC87)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.close,
                              size: 24.0,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                getString('successfully_delivered_title'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  getString(
                                    'successfully_delivered_review_now',
                                  ),
                                  style: TextStyle(
                                    color: Color(0xFF30CFEC),
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: RatingBarIndicator(
                                  rating: 5,
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemSize: 24.0,
                                  itemPadding: EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 32.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WriteAReviewPage(
                                              reviewableType: "order",
                                              reviewableId: widget
                                                  .orderDetails.id
                                                  .toString(),
                                              orderDetails: widget.orderDetails,
                                            ),
                                          ),
                                        );
                                      },
                                      child: buildReviewSection(
                                        getString(
                                          'successfully_delivered_order_review',
                                        ),
                                        Color(0xFF02AEFF),
                                        "images/ic_order_review.png",
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _visitDeliveryReview(context);
                                      },
                                      child: buildReviewSection(
                                        getString(
                                          'successfully_delivered_delivery_review',
                                        ),
                                        Color(0xFFF75F55),
                                        "images/ic_delivery_review.png",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _visitDeliveryReview(BuildContext context) {
    if (widget.orderDetails != null &&
        widget.orderDetails.consignments.isNotEmpty &&
        widget.orderDetails.consignments.first.deliveryManId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WriteAReviewPage(
            reviewableType: "delivery_man",
            reviewableId:
                widget.orderDetails.consignments.first.deliveryManId.toString(),
            orderDetails: widget.orderDetails,
          ),
        ),
      );
    }
  }

  Widget buildReviewSection(
    String title,
    Color backgroundColor,
    String imagePath,
  ) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
          ),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 32.0,
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}
