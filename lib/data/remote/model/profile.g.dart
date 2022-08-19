// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'name']);
  return Profile(
    id: json['id'] as int,
    username: json['username'] as String ?? '',
    name: json['name'] as String,
    avatar: json['avatar'] as String ??
        'https://www.w3schools.com/w3images/avatar2.png',
    email: json['email'] as String ?? '',
    phone: json['phone'] as String ?? '',
    status: json['status'] as int,
    pushNotification: json['push_notification'] as int ?? 0,
    createdAt: json['created_at'] as String ?? '',
    balance: json['balance'] ?? 0,
  );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatar': instance.avatar,
      'email': instance.email,
      'phone': instance.phone,
      'created_at': instance.createdAt,
      'status': instance.status,
      'push_notification': instance.pushNotification,
      'balance': instance.balance,
    };
