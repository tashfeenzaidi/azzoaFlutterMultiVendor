import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/notification_type_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationData {
  @JsonKey(defaultValue: kDefaultString)
  String title;

  @JsonKey(defaultValue: kDefaultString)
  String message;

  @JsonKey(defaultValue: null)
  NotificationTypeData data;

  NotificationData();

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDataToJson(this);
}
