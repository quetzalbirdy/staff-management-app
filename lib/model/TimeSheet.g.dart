// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TimeSheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeSheet _$TimeSheetFromJson(Map<String, dynamic> json) {
  return TimeSheet(
    updated_at: json['updated_at'] as String,
    timein: json['timein'] as String,
    freelancer_id: json['freelancer_id'] as String,
    created_at: json['created_at'] as String,
    address: json['address'] as String,
    end: json['end'] as String,
    tender_id: json['tender_id'] as String,
    id: json['id'] as String,
    start: json['start'] as String,
    campaign_id: json['campaign_id'] as String,
    shift_id: json['shift_id'] as String,
    authorizer_code: json['authorizer_code'] as String,
    charged: json['charged'] as bool,
    total_pay: json['total_pay'] as String,
    pay_status: json['pay_status'] as String,
    hours: json['hours'] as String,
    income_id: json['income_id'] as String,
    billing: json['billing'] as String,
    timeout: json['timeout'] as String,
    hour_status: json['hour_status'] as String,
    chargable: json['chargable'] as String,
    notes: json['notes'] as String,
    authorizer: json['authorizer'] as String,
    job_type: json['job_type'] as String,
  );
}

Map<String, dynamic> _$TimeSheetToJson(TimeSheet instance) => <String, dynamic>{
      'updated_at': instance.updated_at,
      'timein': instance.timein,
      'freelancer_id': instance.freelancer_id,
      'created_at': instance.created_at,
      'address': instance.address,
      'end': instance.end,
      'tender_id': instance.tender_id,
      'id': instance.id,
      'start': instance.start,
      'campaign_id': instance.campaign_id,
      'shift_id': instance.shift_id,
      'authorizer_code': instance.authorizer_code,
      'charged': instance.charged,
      'total_pay': instance.total_pay,
      'pay_status': instance.pay_status,
      'hours': instance.hours,
      'income_id': instance.income_id,
      'billing': instance.billing,
      'timeout': instance.timeout,
      'hour_status': instance.hour_status,
      'chargable': instance.chargable,
      'notes': instance.notes,
      'authorizer': instance.authorizer,
      'job_type': instance.job_type,
    };
