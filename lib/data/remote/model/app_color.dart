import 'package:json_annotation/json_annotation.dart';

part 'app_color.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AppColor {

  @JsonKey(defaultValue: null)
  String colorPrimary;

  @JsonKey(defaultValue: null)
  String colorPrimaryDark;

  @JsonKey(defaultValue: null)
  String colorAccent;

  @JsonKey(defaultValue: null)
  String buttonColor_1;

  @JsonKey(defaultValue: null)
  String buttonColor_2;

  AppColor();

  factory AppColor.fromJson(Map<String, dynamic> json) =>
      _$AppColorFromJson(json);

  Map<String, dynamic> toJson() => _$AppColorToJson(this);
}
