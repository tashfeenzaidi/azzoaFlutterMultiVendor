import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_summary.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderSummary {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  int userId;

  @JsonKey(defaultValue: null)
  String track;

  @JsonKey(defaultValue: null)
  int couponId;

  @JsonKey(defaultValue: null)
  String couponCode;

  @JsonKey(defaultValue: kDefaultInt)
  double discount;

  @JsonKey(defaultValue: null)
  int shippingMethodId;

  @JsonKey(defaultValue: kDefaultString)
  String shippingMethodName;

  @JsonKey(defaultValue: kDefaultDouble)
  double shippingCharge;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(defaultValue: null)
  int status;

  @JsonKey(defaultValue: kDefaultString)
  String statusString;

  OrderSummary({
    this.id,
    this.userId,
    this.track,
    this.couponId,
    this.couponCode,
    this.discount,
    this.shippingMethodId,
    this.shippingMethodName,
    this.shippingCharge,
    this.status,
    this.createdAt,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);
}
