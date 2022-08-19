import 'dart:collection';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/order_summary.dart';
import 'package:azzoa_grocery/data/remote/response/order_details_response.dart';
import 'package:azzoa_grocery/data/remote/response/order_summary_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/orders/steps/order_steps.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/time.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class TrackingOrderListPage extends StatefulWidget {
  @override
  _TrackingOrderListPageState createState() => _TrackingOrderListPageState();
}

class _TrackingOrderListPageState extends State<TrackingOrderListPage> {
  bool isLoading = false;
  bool isListEmpty = false;
  List<ListItem> _itemList;

  bool hasError;

  int currentPage, lastPage;
  String error;
  List<OrderSummary> list;
  HashMap<String, int> itemCount;
  HashMap<String, bool> headerPlaced;

  ScrollController _scrollController;

  AppConfigNotifier appConfigNotifier;

  Future<void> _getList(
    int page, {
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

      OrderSummaryPaginatedListResponse response =
          await NetworkHelper.on().getOrderHistory(
        context,
        page,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        String currencyCode = await SharedPrefUtil.getString(kKeyCurrency);

        if (page == 1) {
          list.clear();
          itemCount.clear();
          headerPlaced.clear();
        }

        list.addAll(
          response.data.jsonObject.data.where(
            (element) {
              return element.status != 3 && element.status != 5;
            },
          ).map(
            (e) {
              e.createdAt = TimeUtil.getFormattedDateFromText(
                e.createdAt,
                "yyyy-MM-ddTHH:mm:ss.000000Z",
                kTrackingOrderDateTimeFormat,
              );

              if (itemCount.containsKey(e.createdAt)) {
                itemCount[e.createdAt] = itemCount[e.createdAt] + 1;
              } else {
                itemCount.putIfAbsent(e.createdAt, () => 1);
              }

              return e;
            },
          ),
        );

        if (this.mounted) {
          setState(() {
            if (page == 1) {
              _itemList.clear();
            }

            list.forEach((element) {
              if (headerPlaced.containsKey(element.createdAt) &&
                  headerPlaced[element.createdAt]) {
                _itemList.add(
                  BodyItem(
                    item: element,
                    currencyCode: currencyCode,
                    accentColor: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ),
                    appConfigNotifier: appConfigNotifier,
                  ),
                );
              } else {
                _itemList.add(HeaderItem(element.createdAt));
                headerPlaced.putIfAbsent(element.createdAt, () => true);
                _itemList.add(
                  BodyItem(
                    item: element,
                    currencyCode: currencyCode,
                    accentColor: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ),
                    appConfigNotifier: appConfigNotifier,
                  ),
                );
              }
            });

            currentPage = response.data.jsonObject.currentPage;
            lastPage = response.data.jsonObject.lastPage;
            hasError = false;
            isListEmpty = _itemList.isEmpty;

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

  Widget buildErrorBody(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
      ),
    );
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
    this._getList(currentPage);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _itemList = [];
    itemCount = HashMap();
    headerPlaced = HashMap();
    _scrollController = ScrollController();
    isLoading = false;
    hasError = false;
    list = [];
    currentPage = 1;
    error = kDefaultString;
    super.initState();
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
            icon: Icon(Icons.arrow_back_ios, color: kInactiveColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('tracking_orders_toolbar_title'),
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
              : (hasError
                  ? buildErrorBody(error)
                  : (isListEmpty ? buildEmptyPlaceholder() : buildBody())),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 16.0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: buildLinearList(),
          ),
        ),
      ],
    );
  }

  Widget buildLinearList() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: _itemList.length,
      itemBuilder: (BuildContext context, int index) {
        ListItem currentItem = _itemList[index];

        if (currentItem is HeaderItem) {
          return currentItem.build(context);
        } else {
          return currentItem.build(context);
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 8.0,
        );
      },
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}

abstract class ListItem {
  Widget build(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeaderItem implements ListItem {
  final String title;

  HeaderItem(this.title);

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black.withOpacity(0.25),
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A ListItem that contains data to display a message.
class BodyItem implements ListItem {
  final String currencyCode;
  final OrderSummary item;
  final Color accentColor;
  final AppConfigNotifier appConfigNotifier;

  BodyItem({
    @required this.item,
    @required this.currencyCode,
    @required this.accentColor,
    @required this.appConfigNotifier,
  });

  Widget build(BuildContext context) => InkWell(
        onTap: () {
          _visitTrackOrderPage(context, item);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              trailing: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(6.0),
                  color: accentColor.withOpacity(0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    item.statusString,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              title: Text(
                "${getString('order', context)} ${item.id}",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                "${getString('shipping_charge', context)}: ${item.shippingCharge} $currencyCode",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.25),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );

  String getString(String key, BuildContext context) {
    return AppLocalizations.of(context).getString(key);
  }

  void _visitTrackOrderPage(
    BuildContext context,
    OrderSummary summary,
  ) async {
    if (appConfigNotifier.currentLocation != null) {
      try {
        OrderDetailsResponse response =
            await NetworkHelper.on().getOrderDetails(
          context,
          summary.id,
        );

        if (response != null &&
            response.status != null &&
            response.status == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderStepsPage(
                orderDetails: response.data.jsonObject,
              ),
            ),
          );
        } else {
          ToastUtil.show(
            getString('something_went_wrong', context),
          );
        }
      } catch (e) {
        if (!(e is AppException)) {
          ToastUtil.show(
            getString('something_went_wrong', context),
          );
        }
      }
    } else {
      ToastUtil.show(getString('fetch_location_error', context));
    }
  }
}
