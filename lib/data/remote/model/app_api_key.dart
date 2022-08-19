import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_api_key.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AppApiKey {

  @JsonKey(defaultValue: null)
  String googleMapApiKey;

  @JsonKey(defaultValue: kDefaultString)
  String directionApiKey;

  AppApiKey();

  factory AppApiKey.fromJson(Map<String, dynamic> json) =>
      _$AppApiKeyFromJson(json);

  Map<String, dynamic> toJson() => _$AppApiKeyToJson(this);
}
