import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/base/extensions.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/address.dart';
import 'package:azzoa_grocery/data/remote/response/address_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/address/add/add_new_address.dart';
import 'package:azzoa_grocery/ui/address/update/update_address.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ViewAddressPage extends StatefulWidget {
  final String pageTag;

  ViewAddressPage({@required this.pageTag});

  @override
  _ViewAddressPageState createState() => _ViewAddressPageState();
}

class _ViewAddressPageState extends State<ViewAddressPage> {
  bool isLoading = false;
  bool isGettingData = false;
  bool isListEmpty = false;
  bool hasError;

  int currentPage, lastPage;
  String error;
  List<Address> list;

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

      AddressPaginatedListResponse response =
          await NetworkHelper.on().getAddresses(
        context,
        page,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          setState(() {
            if (page == 1) {
              list.clear();
            }

            list.addAll(response.data.jsonObject.data.where((element) {
              return element.type.toLowerCase() == widget.pageTag.toLowerCase();
            }));
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
  void initState() {
    _scrollController = ScrollController();
    isLoading = false;
    hasError = false;
    list = [];
    currentPage = 1;
    error = kDefaultString;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
    isGettingData = true;
    this._getList(currentPage);
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
            "${widget.pageTag.toTitleCase()} ${getString('addresses')}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
              ),
            ),
            SafeArea(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: (hasError
                              ? buildErrorBody(error)
                              : (isListEmpty
                                  ? buildEmptyPlaceholder()
                                  : buildBody())),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 48.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return AddNewAddressPage(
                                      pageTag: widget.pageTag,
                                    );
                                  }),
                                ).then((value) {
                                  if (value != null && value is bool && value) {
                                    isGettingData = true;
                                    _getList(1, loadNeeded: false);
                                  }
                                });
                              },
                              color: ColorUtil.hexToColor(
                                appConfigNotifier.appConfig.color.colorAccent,
                              ),
                              child: Text(
                                getString('add_new_address'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                ),
                              ),
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

  Widget buildBody() {
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
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          Address item = list[index];
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

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return UpdateAddressPage(
                      pageTag: widget.pageTag,
                      item: item,
                    );
                  }),
                ).then((value) {
                  if (value != null && value is bool && value) {
                    isGettingData = true;
                    _getList(1, loadNeeded: false);
                  }
                });
              },
              child: Card(
                elevation: 1.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: ListTile(
                    title: Text(
                      item.streetAddress_1,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        showRemovingBottomSheet(context, item.id);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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

  Future showRemovingBottomSheet(BuildContext context, int itemId) {
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

  Wrap buildBottomSheet(int itemId) {
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
                    getString('view_address_sure_to_delete'),
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
                      getString('no'),
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
                      _deleteAddress(itemId);
                    },
                    color: ColorUtil.hexToColor(
                      appConfigNotifier.appConfig.color.colorAccent,
                    ),
                    child: Text(
                      getString('yes'),
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

  void _deleteAddress(int itemId) async {
    setState(() {
      isLoading = true;
    });

    try {
      BaseResponse response = await NetworkHelper.on().deleteAddress(
        context,
        itemId,
      );

      setState(() {
        isLoading = false;
      });

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        isGettingData = true;
        _getList(1, loadNeeded: false);

        ToastUtil.show(response.message);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('view_address_delete_error'),
        );
      }
    }
  }
}
