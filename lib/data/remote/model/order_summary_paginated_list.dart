import 'package:azzoa_grocery/data/remote/model/order_summary.dart';
import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_summary_paginated_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderSummaryPaginatedList {
  @JsonKey(defaultValue: 1)
  int currentPage;

  @JsonKey(defaultValue: "1")
  int perPage;

  @JsonKey(defaultValue: 1)
  int lastPage;

  @JsonKey(defaultValue: [])
  List<OrderSummary> data;

  OrderSummaryPaginatedList({
    this.data,
  });

  factory OrderSummaryPaginatedList.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryPaginatedListFromJson(json);

  Map<String, dynamic> toJson() => _$OrderSummaryPaginatedListToJson(this);
}
