import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/order_details.dart';
import 'package:azzoa_grocery/data/remote/response/plain_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_product_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_shop_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/keyboard.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class WriteAReviewPage extends StatefulWidget {
  final String reviewableId;
  final String reviewableType;
  final OrderDetails orderDetails;

  WriteAReviewPage({
    @required this.reviewableId,
    @required this.reviewableType,
    this.orderDetails,
  });

  @override
  _WriteAReviewPageState createState() => _WriteAReviewPageState();
}

class _WriteAReviewPageState extends State<WriteAReviewPage> {
  bool isLoading = false;
  double rating;

  TextEditingController _reviewController;

  AppConfigNotifier appConfigNotifier;

  Future _getRightLoad() {
    switch (widget.reviewableType.toLowerCase()) {
      case "shop":
        return NetworkHelper.on().getSingleShop(
          context,
          widget.reviewableId,
        );
        break;

      case "product":
        return NetworkHelper.on().getSingleProduct(
          context,
          widget.reviewableId,
        );
        break;

      default:
        return Future.value(widget.orderDetails);
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );
  }

  @override
  void initState() {
    _reviewController = TextEditingController();
    rating = 5.0;
    super.initState();
  }

  @override
  void dispose() {
    _reviewController.dispose();
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: kInactiveColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: kCommonBackgroundColor,
          elevation: 0.0,
          title: Text(
            getString('write_a_review_toolbar_title'),
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
              : FutureBuilder(
                  future: _getRightLoad(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String title = kDefaultString;
                      String imageUrl = kDefaultString;

                      if (widget.reviewableType.toLowerCase() == "product") {
                        SingleProductResponse response = snapshot.data as SingleProductResponse;

                        if (response != null && response.status != null && response.status == 200) {
                          title = response.data.jsonObject.title;
                          imageUrl = response.data.jsonObject.image;
                        }
                      } else if (widget.reviewableType.toLowerCase() == "shop") {
                        SingleShopResponse response = snapshot.data as SingleShopResponse;

                        if (response != null && response.status != null && response.status == 200) {
                          title = response.data.jsonObject.name;
                          imageUrl = response.data.jsonObject.logo;
                        }
                      } else {
                        OrderDetails orderDetails = snapshot.data as OrderDetails;
                        title = "${getString('order')} #${orderDetails.id}";
                        imageUrl = null;
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  if (widget.reviewableType != "delivery_man" &&
                                      widget.reviewableType != "order")
                                    ListTile(
                                      contentPadding: EdgeInsets.only(
                                        left: 24.0,
                                        right: 24.0,
                                        top: 16.0,
                                        bottom: 32.0,
                                      ),
                                      leading: imageUrl != null
                                          ? Container(
                                              color: Colors.white,
                                              height: 100.0,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10.0),
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : null,
                                      title: Padding(
                                        padding: imageUrl != null
                                            ? const EdgeInsets.all(0.0)
                                            : const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            color: Colors.black.withOpacity(0.5),
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  if (widget.reviewableType == "delivery_man")
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 45,
                                        backgroundImage: NetworkImage(
                                          widget.orderDetails.consignments.first.deliveryMan.avatar,
                                        ),
                                      ),
                                    ),
                                  if (widget.reviewableType == "order")
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFFEB71E).withOpacity(0.2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(28.0),
                                        child: Icon(
                                          Icons.thumb_up,
                                          color: Color(0xFFE69D00),
                                          size: 32.0,
                                        ),
                                      ),
                                    ),
                                  if (widget.reviewableType == "delivery_man")
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16.0,
                                        bottom: 16.0,
                                        left: 32.0,
                                        right: 32.0,
                                      ),
                                      child: Text(
                                        widget.orderDetails.consignments.first.deliveryMan.name,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  if (widget.reviewableType == "order")
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16.0,
                                        bottom: 16.0,
                                        left: 32.0,
                                        right: 32.0,
                                      ),
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  if (widget.reviewableType != "delivery_man" &&
                                      widget.reviewableType != "order")
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 28.0,
                                        right: 28.0,
                                        bottom: 8.0,
                                      ),
                                      child: Text(
                                        getString('write_a_review_rating'),
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  if (widget.reviewableType == "delivery_man" ||
                                      widget.reviewableType == "order")
                                    Center(
                                      child: buildRatingBar(),
                                    )
                                  else
                                    buildRatingBar(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 28.0,
                                      right: 28.0,
                                      bottom: 6.0,
                                    ),
                                    child: Text(
                                      getString('write_a_review_review'),
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.5),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      textAlign: TextAlign.left,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    height: 300,
                                    child: buildTextFormField(
                                      controller: _reviewController,
                                      hint: getString(
                                        'write_a_review_product_experience',
                                      ),
                                      inputType: TextInputType.multiline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buildButton(
                            onPressCallback: () {
                              _addReview();
                            },
                            backgroundColor: ColorUtil.hexToColor(
                              appConfigNotifier.appConfig.color.colorAccent,
                            ),
                            title: getString('write_a_review_Submit'),
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
                ),
        ),
      ),
    );
  }

  Padding buildRatingBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      child: RatingBar(
        initialRating: rating,
        direction: Axis.horizontal,
        maxRating: 5.0,
        minRating: 0.0,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 24.0,
        itemPadding: EdgeInsets.zero,
        // itemBuilder: (context, _) => Icon(
        //   Icons.star,
        //   color: Colors.amber,
        // ),
        onRatingUpdate: (double value) {
          rating = value;
        },
      ),
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

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }

  Widget buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 24.0, 32.0, 24.0),
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

  Widget buildTextFormField({
    TextEditingController controller,
    String hint,
    TextInputType inputType,
    int maxLength,
    Icon icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 2.0, 24.0, 2.0),
      child: Card(
        color: Colors.white,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 24.0,
          ),
          child: TextFormField(
            expands: true,
            obscureText: inputType == TextInputType.visiblePassword,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
            keyboardType: inputType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.5),
              ),
              hintText: hint,
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
            controller: controller,
            maxLines: null,
            minLines: null,
          ),
        ),
      ),
    );
  }

  void _addReview() async {
    KeyboardUtil.hideKeyboard(context);

    setState(() {
      isLoading = true;
    });

    try {
      PlainResponse response = await NetworkHelper.on().addReview(
        context,
        rating.toString(),
        widget.reviewableId,
        widget.reviewableType,
        content: _reviewController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      if (response != null && response.status != null && response.status == 200) {
        _thankUser();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!(e is AppException)) {
        ToastUtil.show(
          getString('write_a_review_error'),
        );
      }
    }
  }

  void _thankUser() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ), //this right here
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFD3A5),
                          Color(0xFFFD6585),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Icon(
                        Icons.thumb_up,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Text(
                      getString('rate_thanks_for_your_feedback'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  FlatButton(
                    padding: const EdgeInsets.only(
                      top: 12.0,
                      bottom: 12.0,
                      left: 8.0,
                      right: 8.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: kAccentColor,
                    child: Text(
                      getString('rate_okay'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ).then(
      (value) => Navigator.of(context).pop(true),
    );
  }
}
