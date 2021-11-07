// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ShiftListHolder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftListHolder _$ShiftListHolderFromJson(Map<String, dynamic> json) {
  return ShiftListHolder(
    company_id: json['company_id'] as int,
    id: json['id'] as int,
    address: json['address'] as String,
    status: json['status'] as String,
    access: json['access'] as String,
    open: json['open'] as int,
    due: json['due'] as String,
    latitude: (json['latitude'] as num)?.toDouble(),
    longitude: (json['longitude'] as num)?.toDouble(),
    start: json['start'] as String,
    end: json['end'] as String,
    contact_name: json['contact_name'] as String,
    price: json['price'] as String,
    client_name: json['client_name'] as String,
    job_type: json['job_type'] as String,
    banner_image: json['banner_image'] as String,
    post_instruction: json['post_instruction'] as String,
    position: json['position'] as int,
    campaign: json['campaign'] == null
        ? null
        : Campaign.fromJson(json['campaign'] as Map<String, dynamic>),
    created_at: json['created_at'] as String,
    isCheckIn: true,
    contact_number: json['contact_number'] as String,
    reported_timesheet: json['reported_timesheet'] == null
        ? null
        : ReportedTimesheet.fromJson(
            json['reported_timesheet'] as Map<String, dynamic>),
    tender: json['tender'] == null
        ? null
        : Tender.fromJson(json['tender'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ShiftListHolderToJson(ShiftListHolder instance) =>
    <String, dynamic>{
      'company_id': instance.company_id,
      'id': instance.id,
      'address': instance.address,
      'status': instance.status,
      'access': instance.access,
      'open': instance.open,
      'due': instance.due,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'start': instance.start,
      'end': instance.end,
      'created_at': instance.created_at,
      'contact_name': instance.contact_name,
      'contact_number': instance.contact_number,
      'price': instance.price,
      'client_name': instance.client_name,
      'job_type': instance.job_type,
      'banner_image': instance.banner_image,
      'post_instruction': instance.post_instruction,
      'position': instance.position,
      'isCheckIn': instance.isCheckIn,
      'campaign': instance.campaign,
      'reported_timesheet': instance.reported_timesheet,
      'tender': instance.tender,
    };
