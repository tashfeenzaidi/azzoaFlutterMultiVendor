import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/cart.dart';
import 'package:azzoa_grocery/data/remote/model/my_cart.dart';
import 'package:azzoa_grocery/data/remote/model/my_review.dart';
import 'package:azzoa_grocery/data/remote/model/single_product.dart';
import 'package:azzoa_grocery/data/remote/model/single_shop.dart';

class ReviewResponse {
  final int status;
  final MyReview data;

  ReviewResponse({
    this.status,
    this.data,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      status: json[kKeyStatus],
      data: MyReview.fromJson(json[kKeyData]),
    );
  }
}
