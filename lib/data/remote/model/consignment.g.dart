// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Consignment _$ConsignmentFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'order_id']);
  return Consignment()
    ..id = json['id'] as int
    ..orderId = json['order_id'] as int
    ..deliveryManId = json['delivery_man_id'] as int
    ..track = json['track'] as String ?? ''
    ..notes = json['notes'] as String ?? ''
    ..startOn = json['start_on'] as String
    ..resolvedOn = json['resolved_on'] as String
    ..status = json['status'] as int ?? ''
    ..createdAt = json['created_at'] as String ?? ''
    ..deliveryMan = json['delivery_man'] == null
        ? null
        : DeliveryMan.fromJson(json['delivery_man'] as Map<String, dynamic>) ??
            '';
}

Map<String, dynamic> _$ConsignmentToJson(Consignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'delivery_man_id': instance.deliveryManId,
      'track': instance.track,
      'notes': instance.notes,
      'start_on': instance.startOn,
      'resolved_on': instance.resolvedOn,
      'status': instance.status,
      'created_at': instance.createdAt,
      'delivery_man': instance.deliveryMan,
    };
