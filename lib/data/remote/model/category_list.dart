import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/category.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CategoryList {

  @JsonKey(defaultValue: [])
  List<Category> jsonArray;

  CategoryList({
    this.jsonArray,
  });

  factory CategoryList.fromJson(Map<String, dynamic> json) => _$CategoryListFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryListToJson(this);
}
