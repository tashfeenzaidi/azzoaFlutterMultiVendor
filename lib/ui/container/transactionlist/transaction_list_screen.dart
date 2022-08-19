import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/order_summary.dart';
import 'package:azzoa_grocery/data/remote/response/order_summary_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/transaction_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/orders/details/order_details.dart';
import 'package:azzoa_grocery/util/helper/debouncer.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TransactionListPage extends StatefulWidget {
  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  bool isLoading = false;
  bool isGettingData = false;
  bool isListEmpty = false;
  bool hasError;

  int currentPage, lastPage;
  String error;
  String orderId;
  List<Transaction> list;

  ScrollController _scrollController;

  String currencyCode = "USD";

  void intiPref() async {
    currencyCode = await SharedPrefUtil.getString(kKeyCurrency);
  }

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

      TransactionListResponse response =
          await NetworkHelper.on().getTransactionList(context);

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          setState(() {
            if (page == 1) {
              list.clear();
            }

            list.addAll(response.data.jsonObject.transaction);
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
    super.initState();
    _scrollController = ScrollController();
    isLoading = false;
    hasError = false;
    list = [];
    currentPage = 1;
    lastPage = 1;
    error = kDefaultString;
    intiPref();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
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
            getString('transaction_list'),
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
          child: hasError ? buildErrorBody(error) : buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : (isListEmpty
                  ? buildEmptyPlaceholder()
                  : NotificationListener(
                      onNotification: (ScrollNotification notification) {
                        if (!isGettingData &&
                            notification.metrics.pixels ==
                                notification.metrics.maxScrollExtent) {
                          if (currentPage < lastPage) {
                            isGettingData = true;
                            this._getList(
                              currentPage + 1,
                              loadNeeded: true,
                            );
                          }
                        }

                        return false;
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          Transaction item = list[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: Card(
                              elevation: 1.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 24.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${item.title}",
                                            style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(.5),
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${item.type} ${item.amount} $currencyCode",
                                            style: TextStyle(
                                              color: item.type == "+"
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      "${getString('transaction_track')} #${item.track}",
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(.5),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )),
        ),
      ],
    );
  }

  Widget buildTextFormField({
    TextEditingController controller,
    String hint,
    TextInputType inputType,
    int maxLength,
    Icon icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 2.0, 32.0, 2.0),
      child: TextFormField(
        obscureText: inputType == TextInputType.visiblePassword,
        style: TextStyle(
          color: kSecondaryTextColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
        keyboardType: inputType,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: kSecondaryTextColor,
          ),
          labelText: hint,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kSecondaryTextColor,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kSecondaryTextColor,
            ),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kSecondaryTextColor,
            ),
          ),
          suffixIcon: icon != null ? icon : SizedBox.shrink(),
        ),
        controller: controller,
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
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
}
