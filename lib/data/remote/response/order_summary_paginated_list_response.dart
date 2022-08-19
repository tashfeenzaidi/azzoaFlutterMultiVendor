import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/order_summary_paginated_object.dart';

class OrderSummaryPaginatedListResponse {
  final int status;
  final OrderSummaryPaginatedObject data;

  OrderSummaryPaginatedListResponse({
    this.status,
    this.data,
  });

  factory OrderSummaryPaginatedListResponse.fromJson(Map<String, dynamic> json) {
    return OrderSummaryPaginatedListResponse(
      status: json[kKeyStatus],
      data: OrderSummaryPaginatedObject.fromJson(json[kKeyData]),
    );
  }
}
