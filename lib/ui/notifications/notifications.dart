import 'dart:collection';

import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/notification.dart';
import 'package:azzoa_grocery/data/remote/response/notification_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = false;
  bool isListEmpty = false;
  List<ListItem> _itemList;

  bool hasError;

  String error;
  List<InAppNotification> list;

  HashMap<String, int> itemCount;
  HashMap<String, bool> headerPlaced;

  AppConfigNotifier appConfigNotifier;

  Future<void> _getList({
    bool loadNeeded = true,
  }) async {
    try {
      if (this.mounted && loadNeeded) {
        setState(() {
          isLoading = true;
        });
      }

      NotificationListResponse response =
          await NetworkHelper.on().getNotificationList(context);

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        list.clear();
        itemCount.clear();
        headerPlaced.clear();

        list.addAll(
          response.data.jsonArray.map(
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
            _itemList.clear();

            list.forEach((element) {
              if (headerPlaced.containsKey(element.createdAt) &&
                  headerPlaced[element.createdAt]) {
                _itemList.add(
                  BodyItem(
                    item: element,
                    appConfigNotifier: appConfigNotifier,
                  ),
                );
              } else {
                _itemList.add(HeaderItem(element.createdAt));
                headerPlaced.putIfAbsent(element.createdAt, () => true);
                _itemList.add(
                  BodyItem(
                    item: element,
                    appConfigNotifier: appConfigNotifier,
                  ),
                );
              }
            });

            hasError = false;
            isListEmpty = _itemList.isEmpty;

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
      } else {
        if (e.toString() != null && e.toString().trim().isNotEmpty) {
          error = e.toString().trim();
        }
      }
    }
  }

  @override
  void initState() {
    _itemList = [];
    itemCount = HashMap();
    headerPlaced = HashMap();
    isLoading = false;
    hasError = false;
    list = [];
    error = kDefaultString;
    super.initState();
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
            getString('notifications_toolbar_title'),
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
                  : (isListEmpty ? buildEmptyPlaceholder() : buildMainBody())),
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

    this._getList();
    super.didChangeDependencies();
  }

  Widget buildMainBody() {
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
            child: buildNotificationList(),
          ),
        ),
      ],
    );
  }

  Widget buildNotificationList() {
    return RefreshIndicator(
      onRefresh: () async {
        await this._getList(loadNeeded: false);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
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
      ),
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
          color: Colors.black.withOpacity(0.5),
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A ListItem that contains data to display a message.
class BodyItem implements ListItem {
  final InAppNotification item;
  final AppConfigNotifier appConfigNotifier;

  BodyItem({
    this.item,
    this.appConfigNotifier,
  });

  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0.0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ).withOpacity(0.1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.notifications,
                      color: ColorUtil.hexToColor(
                        appConfigNotifier.appConfig.color.colorAccent,
                      ).withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.data.title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: Text(
                        item.data.message,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
