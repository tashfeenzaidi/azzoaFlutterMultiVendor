import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateDeliveryPage extends StatefulWidget {
  @override
  RateDeliveryPageState createState() => RateDeliveryPageState();
}

class RateDeliveryPageState extends State<RateDeliveryPage> {
  bool isLoading = false;
  bool isListEmpty = false;

  TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
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
            getString('rate_delivery_toolbar_title'),
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
              : (isListEmpty ? buildEmptyPlaceholder() : buildList()),
        ),
      ),
    );
  }

  Widget buildEmptyPlaceholder() {
    return SizedBox.shrink();
  }

  Widget buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 45,
                backgroundImage: AssetImage(
                  "images/ic_sample_user_avatar.png",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  "Julian Walters",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              RatingBar(
                initialRating: 5.0,
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
                  ToastUtil.show(value.toString());
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16.0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            child: Card(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: buildTextFormField(
                controller: _reviewController,
                hint: getString('write_a_review_product_experience'),
                inputType: TextInputType.multiline,
              ),
            ),
          ),
        ),
        buildButton(
          onPressCallback: () {},
          backgroundColor: kWidgetAccentColor,
          title: getString('rate_delivery_next'),
        ),
      ],
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
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

  Widget buildButton({
    VoidCallback onPressCallback,
    Color backgroundColor,
    String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
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
}
