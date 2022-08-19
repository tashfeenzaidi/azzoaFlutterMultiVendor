import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shop.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Shop {
  @JsonKey(required: true)
  int id;

  @JsonKey(defaultValue: null)
  int shopCategoryId;

  @JsonKey(required: true)
  String name;

  @JsonKey(defaultValue: kDefaultString)
  String slug;

  @JsonKey(defaultValue: kDefaultString)
  String logo;

  @JsonKey(defaultValue: kDefaultString)
  String cover;

  @JsonKey(defaultValue: kDefaultString)
  String address;

  @JsonKey(defaultValue: kDefaultString)
  String latitude;

  @JsonKey(defaultValue: kDefaultString)
  String longitude;

  @JsonKey(defaultValue: kDefaultString)
  String openingAt;

  @JsonKey(defaultValue: kDefaultString)
  String closingAt;

  @JsonKey(defaultValue: kDefaultString)
  String details;

  @JsonKey(defaultValue: kDefaultString)
  String vendorName;

  @JsonKey(defaultValue: kDefaultString)
  String email;

  @JsonKey(defaultValue: kDefaultString)
  String phone;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(defaultValue: false)
  bool openingStatus;

  @JsonKey(defaultValue: kDefaultDouble)
  double star;

  @JsonKey(defaultValue: null)
  int status;

  @JsonKey(defaultValue: kDefaultBoolean)
  bool isFollowing;

  Shop({
    this.id,
    this.shopCategoryId,
    this.name,
    this.slug,
    this.logo,
    this.cover,
    this.address,
    this.latitude,
    this.longitude,
    this.openingAt,
    this.closingAt,
    this.details,
    this.vendorName,
    this.email,
    this.phone,
    this.createdAt,
    this.status,
    this.openingStatus,
    this.star,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);

  Map<String, dynamic> toJson() => _$ShopToJson(this);
}
