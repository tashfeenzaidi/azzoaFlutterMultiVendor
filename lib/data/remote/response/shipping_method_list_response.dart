import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/shipping_method_list.dart';

class ShippingMethodListResponse {
  final int status;
  final ShippingMethodList data;

  ShippingMethodListResponse({
    this.status,
    this.data,
  });

  factory ShippingMethodListResponse.fromJson(Map<String, dynamic> json) {
    return ShippingMethodListResponse(
      status: json[kKeyStatus],
      data: ShippingMethodList.fromJson(json[kKeyData]),
    );
  }
}
