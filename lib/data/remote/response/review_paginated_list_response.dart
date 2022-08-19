import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/category_list.dart';
import 'package:azzoa_grocery/data/remote/model/product_paginated_object.dart';
import 'package:azzoa_grocery/data/remote/model/review_paginated_object.dart';

class ReviewPaginatedListResponse {
  final int status;
  final ReviewPaginatedObject data;

  ReviewPaginatedListResponse({
    this.status,
    this.data,
  });

  factory ReviewPaginatedListResponse.fromJson(Map<String, dynamic> json) {
    return ReviewPaginatedListResponse(
      status: json[kKeyStatus],
      data: ReviewPaginatedObject.fromJson(json[kKeyData]),
    );
  }
}
