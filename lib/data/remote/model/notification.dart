import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/notification_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InAppNotification {
  @JsonKey(defaultValue: kDefaultString)
  String id;

  @JsonKey(defaultValue: kDefaultString)
  String type;

  @JsonKey(defaultValue: kDefaultString)
  String notifiableType;

  @JsonKey(defaultValue: kDefaultInt)
  int notifiableId;

  @JsonKey(defaultValue: null)
  String readAt;

  @JsonKey(defaultValue: null)
  NotificationData data;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  InAppNotification();

  factory InAppNotification.fromJson(Map<String, dynamic> json) =>
      _$InAppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$InAppNotificationToJson(this);
}
