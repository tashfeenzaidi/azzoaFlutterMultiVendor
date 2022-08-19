import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/cart.dart';
import 'package:azzoa_grocery/data/remote/model/my_cart.dart';
import 'package:azzoa_grocery/data/remote/model/single_product.dart';
import 'package:azzoa_grocery/data/remote/model/single_shop.dart';

class CartResponse {
  final int status;
  final MyCart data;

  CartResponse({
    this.status,
    this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      status: json[kKeyStatus],
      data: MyCart.fromJson(json[kKeyData]),
    );
  }
}
