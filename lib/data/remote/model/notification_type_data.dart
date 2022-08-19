import 'package:json_annotation/json_annotation.dart';

part 'notification_type_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationTypeData {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String type;

  NotificationTypeData();

  factory NotificationTypeData.fromJson(Map<String, dynamic> json) =>
      _$NotificationTypeDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationTypeDataToJson(this);
}
