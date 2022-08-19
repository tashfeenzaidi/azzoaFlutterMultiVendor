import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/address_paginated_object.dart';

class AddressPaginatedListResponse {
  final int status;
  final AddressPaginatedObject data;

  AddressPaginatedListResponse({
    this.status,
    this.data,
  });

  factory AddressPaginatedListResponse.fromJson(Map<String, dynamic> json) {
    return AddressPaginatedListResponse(
      status: json[kKeyStatus],
      data: AddressPaginatedObject.fromJson(json[kKeyData]),
    );
  }
}
