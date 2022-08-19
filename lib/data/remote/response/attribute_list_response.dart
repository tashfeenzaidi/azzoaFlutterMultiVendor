import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/attribute_list.dart';

class AttributeListResponse {
  final int status;
  final AttributeList data;

  AttributeListResponse({
    this.status,
    this.data,
  });

  factory AttributeListResponse.fromJson(Map<String, dynamic> json) {
    return AttributeListResponse(
      status: json[kKeyStatus],
      data: AttributeList.fromJson(json[kKeyData]),
    );
  }
}
