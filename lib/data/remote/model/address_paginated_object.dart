import 'package:azzoa_grocery/data/remote/model/address_paginated_list.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_paginated_object.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AddressPaginatedObject {
  @JsonKey(defaultValue: [])
  AddressPaginatedList jsonObject;

  AddressPaginatedObject({
    this.jsonObject,
  });

  factory AddressPaginatedObject.fromJson(Map<String, dynamic> json) =>
      _$AddressPaginatedObjectFromJson(json);

  Map<String, dynamic> toJson() => _$AddressPaginatedObjectToJson(this);
}
