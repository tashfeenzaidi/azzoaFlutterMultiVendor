import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/shop_list.dart';

class ShopListResponse {
  final int status;
  final ShopList data;

  ShopListResponse({
    this.status,
    this.data,
  });

  factory ShopListResponse.fromJson(Map<String, dynamic> json) {
    return ShopListResponse(
      status: json[kKeyStatus],
      data: ShopList.fromJson(json[kKeyData]),
    );
  }
}
