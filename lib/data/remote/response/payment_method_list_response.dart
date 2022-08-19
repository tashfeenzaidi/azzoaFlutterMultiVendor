import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/payment_method_list.dart';

class PaymentMethodListResponse {
  final int status;
  final PaymentMethodList data;

  PaymentMethodListResponse({
    this.status,
    this.data,
  });

  factory PaymentMethodListResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodListResponse(
      status: json[kKeyStatus],
      data: PaymentMethodList.fromJson(json[kKeyData]),
    );
  }
}
