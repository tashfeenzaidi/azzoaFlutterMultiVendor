import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/app_api_key.dart';
import 'package:azzoa_grocery/data/remote/model/app_color.dart';
import 'package:azzoa_grocery/data/remote/model/app_version.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AppConfig {
  @JsonKey(defaultValue: null)
  AppVersion appVersion;

  @JsonKey(defaultValue: null)
  AppColor color;

  @JsonKey(defaultValue: null)
  AppApiKey apiKey;

  @JsonKey(defaultValue: kDefaultString)
  String logo;

  @JsonKey(defaultValue: kDefaultString)
  String name;

  AppConfig();

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}
