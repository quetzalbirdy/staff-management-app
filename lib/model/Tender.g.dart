// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Tender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tender _$TenderFromJson(Map<String, dynamic> json) {
  return Tender(
    availability_freshness: json['availability_freshness'] as String,
  );
}

Map<String, dynamic> _$TenderToJson(Tender instance) => <String, dynamic>{
      'availability_freshness': instance.availability_freshness,
    };
