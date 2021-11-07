// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Campaign _$CampaignFromJson(Map<String, dynamic> json) {
  return Campaign(
    company_id: json['company_id'] as int,
    id: json['id'] as int,
    notes: json['notes'] as String,
    title: json['title'] as String,
    banner_image: json['banner_image'] as String,
    client_name: json['client_name'] as bool,
    address_display: json['address_display'] as String,
    charge_rate: json['charge_rate'] as String,
    job_type: json['job_type'] as String,
    created_at: json['created_at'] as String,
    timesheets: json['timesheets'] as String,
    radius: json['radius'] as int,
    pay_rate_effective_date: json['pay_rate_effective_date'] as String,
    pay_rate: json['pay_rate'] as String,
  );
}

Map<String, dynamic> _$CampaignToJson(Campaign instance) => <String, dynamic>{
      'company_id': instance.company_id,
      'id': instance.id,
      'notes': instance.notes,
      'title': instance.title,
      'banner_image': instance.banner_image,
      'client_name': instance.client_name,
      'address_display': instance.address_display,
      'charge_rate': instance.charge_rate,
      'job_type': instance.job_type,
      'created_at': instance.created_at,
      'timesheets': instance.timesheets,
      'radius': instance.radius,
      'pay_rate': instance.pay_rate,
      'pay_rate_effective_date': instance.pay_rate_effective_date,
    };
