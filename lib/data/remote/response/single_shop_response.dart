import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/single_shop.dart';

class SingleShopResponse {
  final int status;
  final SingleShop data;

  SingleShopResponse({
    this.status,
    this.data,
  });

  factory SingleShopResponse.fromJson(Map<String, dynamic> json) {
    return SingleShopResponse(
      status: json[kKeyStatus],
      data: SingleShop.fromJson(json[kKeyData]),
    );
  }
}
