import 'package:azzoa_grocery/data/remote/model/order_summary_paginated_list.dart';
import 'package:azzoa_grocery/data/remote/model/product_paginated_list.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_summary_paginated_object.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderSummaryPaginatedObject {
  @JsonKey(defaultValue: [])
  OrderSummaryPaginatedList jsonObject;

  OrderSummaryPaginatedObject({
    this.jsonObject,
  });

  factory OrderSummaryPaginatedObject.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryPaginatedObjectFromJson(json);

  Map<String, dynamic> toJson() => _$OrderSummaryPaginatedObjectToJson(this);
}
