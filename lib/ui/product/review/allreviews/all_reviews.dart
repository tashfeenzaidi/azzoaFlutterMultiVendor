import 'package:azzoa_grocery/app_localization.dart';
import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/model/app_config_provider.dart';
import 'package:azzoa_grocery/data/remote/model/review.dart';
import 'package:azzoa_grocery/data/remote/response/review_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/service/api_service.dart';
import 'package:azzoa_grocery/ui/product/review/writereview/write_a_review.dart';
import 'package:azzoa_grocery/util/helper/color.dart';
import 'package:azzoa_grocery/util/helper/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class AllReviewsPage extends StatefulWidget {
  final String reviewableId;
  final String reviewableType;

  AllReviewsPage({
    @required this.reviewableId,
    @required this.reviewableType,
  });

  @override
  _AllReviewsPageState createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  bool isLoading = false;
  bool isGettingData = false;
  bool isListEmpty = false;
  bool hasError;

  int currentPage, lastPage;
  int selectedFilter;
  String error;
  String star;
  List<Review> list;
  List<String> _listFilterOptions;

  ScrollController _scrollController;
  ScrollController _filterScrollController;

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

      ReviewPaginatedListResponse response =
          await NetworkHelper.on().getReviews(
        context,
        page,
        widget.reviewableId,
        widget.reviewableType,
        star: star,
      );

      if (response != null &&
          response.status != null &&
          response.status == 200) {
        if (this.mounted) {
          setState(() {
            if (page == 1) {
              list.clear();
            }

            list.addAll(response.data.jsonObject.data);
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

        if (star == null) {
          if (_filterScrollController.hasClients) {
            _filterScrollController.animateTo(
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

  @override
  void initState() {
    _scrollController = ScrollController();
    _filterScrollController = ScrollController();
    isLoading = false;
    hasError = false;
    list = [];
    selectedFilter = 0;
    currentPage = 1;
    error = kDefaultString;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    appConfigNotifier = Provider.of<AppConfigNotifier>(
      context,
      listen: false,
    );

    _listFilterOptions = [
      getString('all'),
      getString('five'),
      getString('four'),
      getString('three'),
      getString('two'),
      getString('one'),
    ];

    isGettingData = true;
    this._getList(currentPage);
    super.didChangeDependencies();
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
            getString('all_reviews_toolbar_title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.all(18.0),
              child: GestureDetector(
                child: Icon(
                  Icons.add,
                  color: Colors.amber,
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => WriteAReviewPage(
                        reviewableType: widget.reviewableType,
                        reviewableId: widget.reviewableId,
                      ),
                    ),
                  )
                      .then((value) {
                    if (value != null && value is bool && value) {
                      selectedFilter = 0;
                      star = null;
                      isGettingData = true;
                      this._getList(1, loadNeeded: true);
                    }
                  });
                },
              ),
            ),
          ],
        ),
        backgroundColor: kCommonBackgroundColor,
        body: SafeArea(
          child: hasError ? buildErrorBody(error) : buildBody(),
        ),
      ),
    );
  }

  Widget buildFilterList() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 16.0,
          ),
          child: Text(
            getString('filter'),
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            child: ListView.separated(
              controller: _filterScrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _listFilterOptions.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    String item = _listFilterOptions[index];
                    if (DataUtil.isNumeric(item)) {
                      star = item;
                    } else {
                      star = null;
                    }
                    selectedFilter = index;

                    this._getList(1, loadNeeded: true);
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0.0,
                    child: Container(
                      width: 60.0,
                      decoration: BoxDecoration(
                        color: index == selectedFilter
                            ? ColorUtil.hexToColor(
                                appConfigNotifier.appConfig.color.colorAccent,
                              ).withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                        ),
                        child: buildFilterItemBody(
                          _listFilterOptions[index],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: 12.0,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFilterItemBody(String item) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          item,
          style: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (DataUtil.isNumeric(item))
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              Icons.star_rate,
              color: Colors.amber,
              size: 14.0,
            ),
          ),
      ],
    );
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            child: buildFilterList(),
          ),
          Expanded(
            child: buildReviewList(),
          ),
        ],
      ),
    );
  }

  Widget buildReviewList() {
    return isLoading
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
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 20.0,
                          ),
                          child: buildItemBody(list[index]),
                        ),
                      ),
                    );
                  },
                ),
              ));
  }

  Widget buildItemBody(Review item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: NetworkImage(
                item.user.avatar,
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                    ),
                    child: Text(
                      item.user.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  RatingBarIndicator(
                    rating: item.rating,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemSize: 18.0,
                    itemPadding: EdgeInsets.zero,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    unratedColor: Color(0xFFC4C9DA),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (item.content != null && item.content.isNotEmpty)
          SizedBox(
            height: 16.0,
          ),
        if (item.content != null && item.content.isNotEmpty)
          Text(
            item.content ?? kDefaultString,
            style: TextStyle(
              color: Color(0xFF9FA6BB),
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
      ],
    );
  }

  String getString(String key) {
    return AppLocalizations.of(context).getString(key);
  }
}
