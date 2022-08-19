import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/consignment.dart';
import 'package:azzoa_grocery/data/remote/model/ordered_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_details.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderDetails {
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

  @JsonKey(defaultValue: kDefaultDouble)
  double netTotal;

  @JsonKey(defaultValue: kDefaultDouble)
  double taxTotal;

  @JsonKey(defaultValue: kDefaultDouble)
  double grossTotal;

  @JsonKey(defaultValue: [])
  List<OrderedItem> items;

  @JsonKey(defaultValue: [])
  List<Consignment> consignments;

  @JsonKey(defaultValue: kDefaultString)
  String currencyCode;

  OrderDetails();

  factory OrderDetails.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsToJson(this);
}
