import 'package:azzoa_grocery/data/remote/model/notification.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_non_paginated_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationNonPaginatedList {
  @JsonKey(defaultValue: [])
  List<InAppNotification> jsonArray;

  NotificationNonPaginatedList({
    this.jsonArray,
  });

  factory NotificationNonPaginatedList.fromJson(Map<String, dynamic> json) =>
      _$NotificationNonPaginatedListFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationNonPaginatedListToJson(this);
}
