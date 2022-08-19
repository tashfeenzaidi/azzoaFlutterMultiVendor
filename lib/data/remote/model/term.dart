import 'dart:convert';

import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'term.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Term {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  int attributeId;

  @JsonKey(required: true)
  String name;

  @JsonKey(defaultValue: null)
  String slug;

  @JsonKey(defaultValue: null)
  String data;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  Term();

  factory Term.fromJson(Map<String, dynamic> json) => _$TermFromJson(json);

  Map<String, dynamic> toJson() => _$TermToJson(this);

  String toJsonString() => json.encode(toJson());
}
