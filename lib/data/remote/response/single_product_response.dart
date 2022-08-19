import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/single_product.dart';
import 'package:azzoa_grocery/data/remote/model/single_shop.dart';

class SingleProductResponse {
  final int status;
  final SingleProduct data;

  SingleProductResponse({
    this.status,
    this.data,
  });

  factory SingleProductResponse.fromJson(Map<String, dynamic> json) {
    return SingleProductResponse(
      status: json[kKeyStatus],
      data: SingleProduct.fromJson(json[kKeyData]),
    );
  }
}
