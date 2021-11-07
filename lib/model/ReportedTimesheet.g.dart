// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ReportedTimesheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportedTimesheet _$ReportedTimesheetFromJson(Map<String, dynamic> json) {
  return ReportedTimesheet(
    timein: json['timein'] as String,
    timeout: json['timeout'] as String,
  );
}

Map<String, dynamic> _$ReportedTimesheetToJson(ReportedTimesheet instance) =>
    <String, dynamic>{
      'timein': instance.timein,
      'timeout': instance.timeout,
    };
