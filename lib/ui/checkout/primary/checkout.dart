import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/address.dart';
import 'package:azzoa_grocery/data/remote/model/payment_method.dart';
import 'package:azzoa_grocery/data/remote/model/shipping_method.dart';
import 'package:azzoa_grocery/data/remote/response/address_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/payment_method_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/shipping_method_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/address/add/add_new_address.dart';
import 'package:azzoa_grocery/ui/checkout/summary/checkout_summary.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CheckOutPage extends StatefulWidget {
  final String currency;

  CheckOutPage({@required this.currency});

  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  bool isLoading = false;
  int selectedShippingAddress = 0;
  int selectedBillingAddress = 0;
  int selectedShippingMethod = 0;
  int selectedPaymentMethod = 0;
  List<Address> shippingAddressList = [];
  List<Address> billingAddressList = [];
  List<ShippingMethod> shippingMethodList = [];
  List<PaymentMethod> paymentMethodList = [];
  Future<AddressPaginatedListResponse> _loadAddress;

  AppConfigNotifier appConfigNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(context, listen: false,);
    _loadAddress = NetworkHelper.on().getAddresses(context, 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: kCommonBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            getString('checkout_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6B73FF).withOpacity(0.76).withOpacity(0.08),
                      Color(0xFF000DFF).withOpacity(0.9449).withOpacity(0.08),
                    ],
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).size.height / 3) * 2,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32.0,
                                      horizontal: 32.0,
                                    ),
                                    child: Image.asset(
                                      "images/ic_checkout_background.png",
                                      fit: BoxFit.fitHeight,
                                      height: 230,
                                    ),
                                  ),
                                  buildMenu(context),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FlatButton.icon(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(20.0),
                              onPressed: () {
                                if (shippingAddressList.isEmpty ||
                                    billingAddressList.isEmpty ||
                                    shippingMethodList.isEmpty ||
                                    paymentMethodList.isEmpty) {
                                  ToastUtil.show(
                                    getString('checkout_not_sufficient_data'),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CheckOutSummaryPage(
                                          shippingAddress: shippingAddressList[
                                              selectedShippingAddress],
                                          billingAddress: billingAddressList[
                                              selectedBillingAddress],
                                          shippingMethod: shippingMethodList[
                                              selectedShippingMethod],
                                          paymentMethod: paymentMethodList[
                                              selectedPaymentMethod],
                                        );
                                      },
                                    ),
                                  ).then(
                                    (value) {
                                      if (value != null &&
                                          value is bool &&
                                          value) {
                                        Navigator.of(context).pop(value);
                                      }
                                    },
                                  );
                                }
                              },
                              color: ColorUtil.hexToColor(
                                appConfigNotifier.appConfig.color.buttonColor_2,
                              ),
                              label: Text(
                                getString('checkout_cart_summary'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 16.0,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            getItem(
              "images/ic_user_address.png",
              getString('checkout_shipping_address'),
              children: [
                buildShippingAddressSection(context),
              ],
              addButtonCallback: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewAddressPage(
                      pageTag: "shipping",
                    ),
                  ),
                ).then((value) {
                  if (this.mounted && value != null && value is bool && value) {
                    this.setState(() {
                      _loadAddress =
                          NetworkHelper.on().getAddresses(context, 1);
                    });
                  }
                });
              },
            ),
            getItem(
              "images/ic_user_address.png",
              getString('checkout_billing_address'),
              children: [
                buildBillingAddressSection(context),
              ],
              addButtonCallback: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewAddressPage(
                      pageTag: "billing",
                    ),
                  ),
                ).then((value) {
                  if (this.mounted && value != null && value is bool && value) {
                    this.setState(() {
                      _loadAddress =
                          NetworkHelper.on().getAddresses(context, 1);
                    });
                  }
                });
              },
            ),
            getItem(
              "images/ic_shipping_method.png",
              getString('checkout_shipping_method'),
              children: [
                buildShippingMethodSection(context),
              ],
            ),
            getItem(
              "images/ic_payment_method.png",
              getString('checkout_payment_method'),
              children: [
                buildPaymentMethodSection(context),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildShippingAddressSection(
    BuildContext context,
  ) {
    return FutureBuilder(
      future: _loadAddress,
      builder: (
        context,
        AsyncSnapshot<AddressPaginatedListResponse> snapshot,
      ) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200) {
          shippingAddressList.clear();

          if (shippingAddressList.isEmpty) {
            shippingAddressList.addAll(
              snapshot.data.data.jsonObject.data.where(
                (element) {
                  return element.type.toLowerCase() == "shipping";
                },
              ),
            );
          }

          if (shippingAddressList.isEmpty) {
            return buildEmptyPlaceholder();
          } else {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: shippingAddressList.length,
              itemBuilder: (BuildContext context, int index) {
                Address item = shippingAddressList[index];

                if (index == 0) {
                  shippingAddressList[selectedShippingAddress].isSelected =
                      true;
                }

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

                return InkWell(
                  onTap: () {
                    if (this.mounted) {
                      this.setState(() {
                        shippingAddressList[selectedShippingAddress]
                            .isSelected = false;
                        selectedShippingAddress = index;
                        shippingAddressList[selectedShippingAddress]
                            .isSelected = true;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF14BC9F).withOpacity(0.07),
                      border: Border(
                        top: BorderSide(color: kDividerColor),
                      ),
                    ),
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
                      trailing: Radio(
                        activeColor: Color(0xFF24C030),
                        value: item.isSelected ? 1 : 0,
                        groupValue: 1,
                        onChanged: (value) {
                          if (this.mounted) {
                            this.setState(() {
                              shippingAddressList[selectedShippingAddress]
                                  .isSelected = false;
                              selectedShippingAddress = index;
                              shippingAddressList[selectedShippingAddress]
                                  .isSelected = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          String errorMessage = getString('something_went_wrong');

          if (snapshot.hasError &&
              snapshot.error is AppException &&
              snapshot.error.toString().trim().isNotEmpty) {
            errorMessage = snapshot.error.toString().trim();
          }

          return buildErrorBody(errorMessage);
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget buildBillingAddressSection(
    BuildContext context,
  ) {
    return FutureBuilder(
      future: _loadAddress,
      builder: (
        context,
        AsyncSnapshot<AddressPaginatedListResponse> snapshot,
      ) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200) {
          billingAddressList.clear();

          if (billingAddressList.isEmpty) {
            billingAddressList.addAll(
              snapshot.data.data.jsonObject.data.where(
                (element) {
                  return element.type.toLowerCase() == "billing";
                },
              ),
            );
          }

          if (billingAddressList.isEmpty) {
            return buildEmptyPlaceholder();
          } else {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: billingAddressList.length,
              itemBuilder: (BuildContext context, int index) {
                Address item = billingAddressList[index];

                if (index == 0) {
                  billingAddressList[selectedBillingAddress].isSelected = true;
                }

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

                return InkWell(
                  onTap: () {
                    if (this.mounted) {
                      this.setState(() {
                        billingAddressList[selectedBillingAddress].isSelected =
                            false;
                        selectedBillingAddress = index;
                        billingAddressList[selectedBillingAddress].isSelected =
                            true;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF14BC9F).withOpacity(0.07),
                      border: Border(
                        top: BorderSide(color: kDividerColor),
                      ),
                    ),
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
                      trailing: Radio(
                        activeColor: Color(0xFF24C030),
                        value: item.isSelected ? 1 : 0,
                        groupValue: 1,
                        onChanged: (value) {
                          if (this.mounted) {
                            this.setState(() {
                              billingAddressList[selectedBillingAddress]
                                  .isSelected = false;
                              selectedBillingAddress = index;
                              billingAddressList[selectedBillingAddress]
                                  .isSelected = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          String errorMessage = getString('something_went_wrong');

          if (snapshot.hasError &&
              snapshot.error is AppException &&
              snapshot.error.toString().trim().isNotEmpty) {
            errorMessage = snapshot.error.toString().trim();
          }

          return buildErrorBody(errorMessage);
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget buildShippingMethodSection(
    BuildContext context,
  ) {
    return FutureBuilder(
      future: NetworkHelper.on().getShippingMethods(context),
      builder: (
        context,
        AsyncSnapshot<ShippingMethodListResponse> snapshot,
      ) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200) {
          if (shippingMethodList.isEmpty) {
            shippingMethodList.addAll(snapshot.data.data.jsonArray);
          }

          if (shippingMethodList.isEmpty) {
            return buildEmptyPlaceholder();
          } else {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: shippingMethodList.length,
              itemBuilder: (BuildContext context, int index) {
                ShippingMethod item = shippingMethodList[index];

                if (index == 0) {
                  shippingMethodList[selectedShippingMethod].isSelected = true;
                }

                return InkWell(
                  onTap: () {
                    if (this.mounted) {
                      this.setState(() {
                        shippingMethodList[selectedShippingMethod].isSelected =
                            false;
                        selectedShippingMethod = index;
                        shippingMethodList[selectedShippingMethod].isSelected =
                            true;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFB9130).withOpacity(0.07),
                      border: Border(
                        top: BorderSide(color: kDividerColor),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
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
                          "${item.charge} ${widget.currency}",
                          style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      trailing: Radio(
                        activeColor: Color(0xFF24C030),
                        value: item.isSelected ? 1 : 0,
                        groupValue: 1,
                        onChanged: (value) {
                          if (this.mounted) {
                            this.setState(() {
                              shippingMethodList[selectedShippingMethod]
                                  .isSelected = false;
                              selectedShippingMethod = index;
                              shippingMethodList[selectedShippingMethod]
                                  .isSelected = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          String errorMessage = getString('something_went_wrong');

          if (snapshot.hasError &&
              snapshot.error is AppException &&
              snapshot.error.toString().trim().isNotEmpty) {
            errorMessage = snapshot.error.toString().trim();
          }

          return buildErrorBody(errorMessage);
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget buildPaymentMethodSection(
    BuildContext context,
  ) {
    return FutureBuilder(
      future: NetworkHelper.on().getPaymentMethods(context),
      builder: (
        context,
        AsyncSnapshot<PaymentMethodListResponse> snapshot,
      ) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.status != null &&
            snapshot.data.status == 200) {
          if (paymentMethodList.isEmpty) {
            paymentMethodList.addAll(snapshot.data.data.jsonArray);
          }

          if (paymentMethodList.isEmpty) {
            return buildEmptyPlaceholder();
          } else {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: paymentMethodList.length,
              itemBuilder: (BuildContext context, int index) {
                PaymentMethod item = paymentMethodList[index];

                if (index == 0) {
                  paymentMethodList[selectedPaymentMethod].isSelected = true;
                }

                return InkWell(
                  onTap: () {
                    if (this.mounted) {
                      this.setState(() {
                        paymentMethodList[selectedPaymentMethod].isSelected =
                            false;
                        selectedPaymentMethod = index;
                        paymentMethodList[selectedPaymentMethod].isSelected =
                            true;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF3B04DB).withOpacity(0.07),
                      border: Border(
                        top: BorderSide(color: kDividerColor),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
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
                          item.description ?? kDefaultString,
                          style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      trailing: Radio(
                        activeColor: Color(0xFF24C030),
                        value: item.isSelected ? 1 : 0,
                        groupValue: 1,
                        onChanged: (value) {
                          if (this.mounted) {
                            this.setState(() {
                              paymentMethodList[selectedPaymentMethod]
                                  .isSelected = false;
                              selectedPaymentMethod = index;
                              paymentMethodList[selectedPaymentMethod]
                                  .isSelected = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          String errorMessage = getString('something_went_wrong');

          if (snapshot.hasError &&
              snapshot.error is AppException &&
              snapshot.error.toString().trim().isNotEmpty) {
            errorMessage = snapshot.error.toString().trim();
          }

          return buildErrorBody(errorMessage);
        }

        return SizedBox.shrink();
      },
    );
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

  Widget getItem(
    String imagePath,
    String title, {
    List<Widget> children = const [],
    VoidCallback addButtonCallback,
  }) {
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 20.0,
      ),
      children: children,
      leading: Image.asset(
        imagePath,
        height: 40,
        fit: BoxFit.cover,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (addButtonCallback != null)
            InkWell(
              onTap: addButtonCallback,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorUtil.hexToColor(
                    appConfigNotifier.appConfig.color.colorAccent,
                  ).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    getString('add'),
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
        ],
      ),
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}
