import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/order_details_object.dart';
import 'package:azzoa_grocery/data/remote/model/order_summary_paginated_object.dart';

class OrderDetailsResponse {
  final int status;
  final OrderDetailsObject data;

  OrderDetailsResponse({
    this.status,
    this.data,
  });

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      status: json[kKeyStatus],
      data: OrderDetailsObject.fromJson(json[kKeyData]),
    );
  }
}
