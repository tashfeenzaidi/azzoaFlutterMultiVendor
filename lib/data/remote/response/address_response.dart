import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/address_object.dart';

class AddressResponse {
  final int status;
  final AddressObject data;

  AddressResponse({
    this.status,
    this.data,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      status: json[kKeyStatus],
      data: AddressObject.fromJson(json[kKeyData]),
    );
  }
}
