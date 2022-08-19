import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/category_list.dart';
import 'package:azzoa_grocery/data/remote/model/product_paginated_object.dart';

class ProductPaginatedListResponse {
  final int status;
  final ProductPaginatedObject data;

  ProductPaginatedListResponse({
    this.status,
    this.data,
  });

  factory ProductPaginatedListResponse.fromJson(Map<String, dynamic> json) {
    return ProductPaginatedListResponse(
      status: json[kKeyStatus],
      data: ProductPaginatedObject.fromJson(json[kKeyData]),
    );
  }
}
