import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/cart.dart';
import 'package:azzoa_grocery/data/remote/model/my_cart.dart';
import 'package:azzoa_grocery/data/remote/model/my_wish_list.dart';
import 'package:azzoa_grocery/data/remote/model/single_product.dart';
import 'package:azzoa_grocery/data/remote/model/single_shop.dart';

class WishListResponse {
  final int status;
  final MyWishList data;

  WishListResponse({
    this.status,
    this.data,
  });

  factory WishListResponse.fromJson(Map<String, dynamic> json) {
    return WishListResponse(
      status: json[kKeyStatus],
      data: MyWishList.fromJson(json[kKeyData]),
    );
  }
}
