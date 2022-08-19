import 'package:azzoa_grocery/data/remote/model/attribute.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attribute_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AttributeList {
  @JsonKey(defaultValue: [])
  List<Attribute> jsonArray;

  AttributeList();

  factory AttributeList.fromJson(Map<String, dynamic> json) =>
      _$AttributeListFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeListToJson(this);
}
