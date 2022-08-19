import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/notification_non_paginated_list.dart';

class NotificationListResponse {
  final int status;
  final NotificationNonPaginatedList data;

  NotificationListResponse({
    this.status,
    this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      status: json[kKeyStatus],
      data: NotificationNonPaginatedList.fromJson(json[kKeyData]),
    );
  }
}
