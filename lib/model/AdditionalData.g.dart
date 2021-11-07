// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AdditionalData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdditionalData _$AdditionalDataFromJson(Map<String, dynamic> json) {
  return AdditionalData(
    custom_requirement_id: json['custom_requirement_id'] as int,
    question: json['question'] as String,
    field_type: json['field_type'] as String,
    units: json['units'] as String,
    required_level: json['required_level'] as String,
    description: json['description'] as String,
    value: json['value'] as String,
    options: (json['options'] as List)?.map((e) => e as String)?.toList(),
    isCheck: true,
  );
}

Map<String, dynamic> _$AdditionalDataToJson(AdditionalData instance) =>
    <String, dynamic>{
      'custom_requirement_id': instance.custom_requirement_id,
      'question': instance.question,
      'field_type': instance.field_type,
      'units': instance.units,
      'required_level': instance.required_level,
      'description': instance.description,
      'value': instance.value,
      'options': instance.options,
      'isCheck': instance.isCheck,
    };
