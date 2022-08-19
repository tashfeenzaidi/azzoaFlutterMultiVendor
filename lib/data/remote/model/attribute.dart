import 'dart:convert';

import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/term.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attribute.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Attribute {
  @JsonKey(required: true)
  int id;

  @JsonKey(defaultValue: null)
  int productId;

  @JsonKey(defaultValue: null)
  int attributeId;

  @JsonKey(required: true)
  String name;

  @JsonKey(defaultValue: null)
  String title;

  @JsonKey(defaultValue: null)
  String type;

  @JsonKey(defaultValue: null)
  String slug;

  @JsonKey(defaultValue: null)
  int position;

  @JsonKey(defaultValue: [])
  List<String> content;

  @JsonKey(defaultValue: [])
  List<Term> terms;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  Attribute();

  factory Attribute.fromJson(Map<String, dynamic> json) =>
      _$AttributeFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeToJson(this);

  String toJsonString() => json.encode(toJson());
}
