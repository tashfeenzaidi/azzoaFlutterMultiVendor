import 'dart:async';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/order_details.dart';
import 'package:azzoa_grocery/ui/orders/track/track_order.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/location.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class OrderStepsPage extends StatefulWidget {
  final OrderDetails orderDetails;

  OrderStepsPage({@required this.orderDetails});

  @override
  _OrderStepsPageState createState() => _OrderStepsPageState();
}

class _OrderStepsPageState extends State<OrderStepsPage> {
  bool isLoading = false;
  bool hasError = false;
  double deliveryManLatitude;
  double deliveryManLongitude;

  List<Step> _stepList;
  TextStyle _stepTitleTextStyle = TextStyle(
    color: Color(0xFF282828),
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  AppConfigNotifier appConfigNotifier;

  DatabaseReference _deliveryManPositionRef;
  StreamSubscription<Event> _deliveryManPositionSubscription;

  @override
  void initState() {
    if (widget.orderDetails.consignments.isNotEmpty) {
      _deliveryManPositionRef = FirebaseDatabase.instance
          .reference()
          .child("azzoa")
          .child("order_tracking")
          .child(widget.orderDetails.consignments.first.track);

      _deliveryManPositionRef.keepSynced(true);
      _deliveryManPositionSubscription = _deliveryManPositionRef.onValue.listen((Event event) {
        try {
          deliveryManLatitude = double.parse(
            event.snapshot.value["latitude"] as String,
          );

          deliveryManLongitude = double.parse(
            event.snapshot.value["longitude"] as String,
          );

          setState(() {
            hasError = false;
          });
        } catch (e) {
          setState(() {
            hasError = true;
          });
        }
      }, onError: (Object o) {
        setState(() {
          hasError = true;
        });
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_deliveryManPositionSubscription != null) {
      _deliveryManPositionSubscription.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );

    _stepList = [
      Step(
        isActive: widget.orderDetails.status >= 0 && widget.orderDetails.status < 4,
        title: Text(
          getString('pending'),
          style: _stepTitleTextStyle,
        ),
        content: SizedBox.shrink(),
      ),
      Step(
        isActive: widget.orderDetails.status >= 1 && widget.orderDetails.status < 4,
        title: Text(
          getString('processing'),
          style: _stepTitleTextStyle,
        ),
        content: SizedBox.shrink(),
      ),
      if (widget.orderDetails.status == 4)
        Step(
          isActive: true,
          title: Text(
            getString('hold'),
            style: _stepTitleTextStyle,
          ),
          content: SizedBox.shrink(),
        ),
      if (widget.orderDetails.status == 5)
        Step(
          isActive: true,
          state: StepState.error,
          title: Text(
            getString('canceled'),
            style: _stepTitleTextStyle,
          ),
          content: SizedBox.shrink(),
        ),
      Step(
        isActive: widget.orderDetails.status >= 2 && widget.orderDetails.status < 4,
        title: Text(
          getString('on_the_way'),
          style: _stepTitleTextStyle,
        ),
        content: SizedBox.shrink(),
      ),
      Step(
        isActive: widget.orderDetails.status >= 3 && widget.orderDetails.status < 4,
        title: Text(
          getString('completed'),
          style: _stepTitleTextStyle,
        ),
        content: SizedBox.shrink(),
      ),
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
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
          backgroundColor: Color(0xFFF9FAFB),
          elevation: 0.0,
          title: Text(
            "${getString('order')} # ${widget.orderDetails.id}",
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
          child: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32.0,
                        right: 32.0,
                        top: 16.0,
                      ),
                      child: Text(
                        getString('thank_you'),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32.0,
                        right: 32.0,
                        bottom: 32.0,
                        top: 8.0,
                      ),
                      child: Text(
                        getString('delivery_subtitle'),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.25),
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.orderDetails.status == 0 || widget.orderDetails.status == 1)
                      SpinKitThreeBounce(
                        size: 24,
                        color: ColorUtil.hexToColor(
                          appConfigNotifier.appConfig.color.colorAccent,
                        ),
                      ),
                    if (widget.orderDetails.status == 2 &&
                        !hasError &&
                        deliveryManLatitude != null &&
                        deliveryManLongitude != null &&
                        appConfigNotifier.currentLocation.latitude != null &&
                        appConfigNotifier.currentLocation.longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 32.0,
                          right: 32.0,
                          bottom: 16.0,
                        ),
                        child: Text(
                          "${LocationUtil.calculateTimeInMinutes(
                            appConfigNotifier.currentLocation.latitude,
                            appConfigNotifier.currentLocation.longitude,
                            deliveryManLatitude,
                            deliveryManLongitude,
                            30.0,
                          )} ${getString('minutes')}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 50.0,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Theme(
                          data: ThemeData(
                            primaryColor: Color(0xFF02CC87),
                          ),
                          child: Stepper(
                            steps: _stepList,
                            currentStep: _stepList.length - 1,
                            // controlsBuilder: (
                            //   BuildContext context, {
                            //   VoidCallback onStepContinue,
                            //   VoidCallback onStepCancel,
                            // }) =>
                            //     Container(),
                          ),
                        ),
                      ),
                    ),
                    if (widget.orderDetails.status == 2)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: buildButton(
                          onPressCallback: () {
                            if (widget.orderDetails.consignments.isNotEmpty) {
                              _visitTrackOrderPage(
                                context,
                                widget.orderDetails.consignments.first.track,
                              );
                            }
                          },
                          backgroundColor: ColorUtil.hexToColor(
                            appConfigNotifier.appConfig.color.colorAccent,
                          ),
                          title: getString('see_map'),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  void _visitTrackOrderPage(
    BuildContext context,
    String trackingNumber,
  ) {
    if (appConfigNotifier.currentLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrackOrderPage(
            latitude: appConfigNotifier.currentLocation.latitude,
            longitude: appConfigNotifier.currentLocation.longitude,
            trackingNumber: trackingNumber,
          ),
        ),
      );
    } else {
      ToastUtil.show(
        getString('fetch_location_error'),
      );
    }
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
}
