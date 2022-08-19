// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_man.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryMan _$DeliveryManFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return DeliveryMan()
    ..id = json['id'] as int
    ..username = json['username'] as String ?? ''
    ..name = json['name'] as String ?? ''
    ..email = json['email'] as String ?? ''
    ..phone = json['phone'] as String ?? ''
    ..avatar = json['avatar'] as String ??
        'https://www.w3schools.com/w3images/avatar2.png'
    ..status = json['status'] as int ?? ''
    ..createdAt = json['created_at'] as String ?? '';
}

Map<String, dynamic> _$DeliveryManToJson(DeliveryMan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
