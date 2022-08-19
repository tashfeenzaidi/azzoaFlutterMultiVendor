import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateShopPage extends StatefulWidget {
  @override
  RateShopPageState createState() => RateShopPageState();
}

class RateShopPageState extends State<RateShopPage> {
  bool isLoading = false;
  bool isListEmpty = false;
  List<ListItem> _itemList;

  @override
  void initState() {
    _itemList = List<ListItem>.generate(
      20,
      (i) => BodyItem(
        this,
        "Rating Option",
        i % 6 == 0,
      ),
    );

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
            getString('rate_shop_toolbar_title'),
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
                  "images/ic_sample_vendor.png",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  "Joka Main Store",
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
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "Excellent",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
              child: buildLinearList(),
            ),
          ),
        ),
        buildButton(
          onPressCallback: () {
            thankUser();
          },
          backgroundColor: kWidgetAccentColor,
          title: getString('rate_shop_next'),
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
          height: 0.0,
        );
      },
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

  void thankUser() {
    showDialog(
        context: context,
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
                      onPressed: () {},
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
        });
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
  final String title;
  bool isChecked;
  final RateShopPageState parentState;

  BodyItem(this.parentState, this.title, this.isChecked);

  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0.0,
        color: Colors.white,
        child: CheckboxListTile(
          activeColor: Color(0xFF24C030),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          value: isChecked,
          onChanged: (bool value) {
            if (this.parentState.mounted) {
              this.parentState.setState(() {
                isChecked = !isChecked;
              });
            }
          },
        ),
      );
}
