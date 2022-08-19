import 'package:azzoa_grocery/data/remote/model/address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_object.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AddressObject {
  @JsonKey(required: true)
  Address jsonObject;

  AddressObject({
    this.jsonObject,
  });

  factory AddressObject.fromJson(Map<String, dynamic> json) =>
      _$AddressObjectFromJson(json);

  Map<String, dynamic> toJson() => _$AddressObjectToJson(this);
}
