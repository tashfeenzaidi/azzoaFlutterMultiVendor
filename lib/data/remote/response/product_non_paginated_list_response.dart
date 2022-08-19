import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/category_list.dart';
import 'package:azzoa_grocery/data/remote/model/product_non_paginated_list.dart';
import 'package:azzoa_grocery/data/remote/model/product_paginated_object.dart';

class ProductNonPaginatedListResponse {
  final int status;
  final ProductNonPaginatedList data;

  ProductNonPaginatedListResponse({
    this.status,
    this.data,
  });

  factory ProductNonPaginatedListResponse.fromJson(Map<String, dynamic> json) {
    return ProductNonPaginatedListResponse(
      status: json[kKeyStatus],
      data: ProductNonPaginatedList.fromJson(json[kKeyData]),
    );
  }
}
