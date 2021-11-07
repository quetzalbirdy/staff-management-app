// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PendingShift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingShift _$PendingShiftFromJson(Map<String, dynamic> json) {
  return PendingShift(
    company_id: json['company_id'] as int,
    id: json['id'] as int,
    address: json['address'] as String,
    status: json['status'] as String,
    access: json['access'] as String,
    open: json['open'] as int,
    latitude: (json['latitude'] as num)?.toDouble(),
    longitude: (json['longitude'] as num)?.toDouble(),
    start: json['start'] as String,
    end: json['end'] as String,
    isCheck: json['isCheck'] as bool,
    contact_name: json['contact_name'] as String,
    contact_number: json['contact_number'] as String,
    post_instruction: json['post_instruction'] as String,
  );
}

Map<String, dynamic> _$PendingShiftToJson(PendingShift instance) =>
    <String, dynamic>{
      'company_id': instance.company_id,
      'id': instance.id,
      'address': instance.address,
      'status': instance.status,
      'access': instance.access,
      'open': instance.open,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'start': instance.start,
      'end': instance.end,
      'post_instruction': instance.post_instruction,
      'isCheck': instance.isCheck,
      'contact_name': instance.contact_name,
      'contact_number': instance.contact_number,
    };
