import 'package:azzoa_grocery/data/remote/model/address.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_paginated_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AddressPaginatedList {
  @JsonKey(defaultValue: 1)
  int currentPage;

  @JsonKey(defaultValue: "1")
  int perPage;

  @JsonKey(defaultValue: 1)
  int lastPage;

  @JsonKey(defaultValue: [])
  List<Address> data;

  AddressPaginatedList({
    this.data,
  });

  factory AddressPaginatedList.fromJson(Map<String, dynamic> json) =>
      _$AddressPaginatedListFromJson(json);

  Map<String, dynamic> toJson() => _$AddressPaginatedListToJson(this);
}
