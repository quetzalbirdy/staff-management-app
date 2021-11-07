// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PendingShiftsHolder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingShiftsHolder _$PendingShiftsHolderFromJson(Map<String, dynamic> json) {
  return PendingShiftsHolder(
    tender_id: json['tender_id'] as int,
    tender_status: json['tender_status'] as String,
    price: json['price'] as String,
    start: json['start'] as String,
    end: json['end'] as String,
    address: json['address'] as String,
    title: json['title'] as String,
    client: json['client'] as String,
    notes: json['notes'] as String,
    campaign_id: json['campaign_id'] as int,
    shift: json['shift'] == null
        ? null
        : PendingShift.fromJson(json['shift'] as Map<String, dynamic>),
    shift_id: json['shift_id'] as int,
    is_full: json['is_full'] as bool,
  );
}

Map<String, dynamic> _$PendingShiftsHolderToJson(
        PendingShiftsHolder instance) =>
    <String, dynamic>{
      'tender_status': instance.tender_status,
      'start': instance.start,
      'end': instance.end,
      'address': instance.address,
      'title': instance.title,
      'client': instance.client,
      'price': instance.price,
      'notes': instance.notes,
      'tender_id': instance.tender_id,
      'shift_id': instance.shift_id,
      'campaign_id': instance.campaign_id,
      'shift': instance.shift,
      'is_full': instance.is_full,
    };
