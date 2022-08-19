import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/delivery_man.dart';
import 'package:json_annotation/json_annotation.dart';

part 'consignment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Consignment {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  int orderId;

  @JsonKey(defaultValue: null)
  int deliveryManId;

  @JsonKey(defaultValue: kDefaultString)
  String track;

  @JsonKey(defaultValue: kDefaultString)
  String notes;

  @JsonKey(defaultValue: null)
  String startOn;

  @JsonKey(defaultValue: null)
  String resolvedOn;

  @JsonKey(defaultValue: kDefaultString)
  int status;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(defaultValue: kDefaultString)
  DeliveryMan deliveryMan;

  Consignment();

  factory Consignment.fromJson(Map<String, dynamic> json) =>
      _$ConsignmentFromJson(json);

  Map<String, dynamic> toJson() => _$ConsignmentToJson(this);
}
