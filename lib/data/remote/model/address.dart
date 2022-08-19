import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Address {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  int userId;

  @JsonKey(required: true)
  String type;

  @JsonKey(defaultValue: kDefaultString)
  String name;

  @JsonKey(defaultValue: kDefaultString)
  String email;

  @JsonKey(defaultValue: kDefaultString)
  String phone;

  @JsonKey(defaultValue: kDefaultString)
  String country;

  @JsonKey(defaultValue: kDefaultString)
  String state;

  @JsonKey(defaultValue: kDefaultString)
  String city;

  @JsonKey(defaultValue: kDefaultString)
  String streetAddress_1;

  @JsonKey(defaultValue: kDefaultString)
  String streetAddress_2;

  @JsonKey(defaultValue: kDefaultString)
  String latitude;

  @JsonKey(defaultValue: kDefaultString)
  String longitude;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(ignore: true)
  bool isSelected = false;

  Address({
    this.id,
    this.userId,
    this.type,
    this.name,
    this.email,
    this.phone,
    this.country,
    this.state,
    this.city,
    this.streetAddress_1,
    this.streetAddress_2,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
