// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shifts _$ShiftsFromJson(Map<String, dynamic> json) {
  return Shifts(
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
    isCheck: true,
    contact_name: json['contact_name'] as String,
  );
}

Map<String, dynamic> _$ShiftsToJson(Shifts instance) => <String, dynamic>{
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
      'isCheck': instance.isCheck,
      'contact_name': instance.contact_name,
    };
