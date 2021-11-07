// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) {
  return Job(
    campaigns: (json['campaigns'] as List)
        ?.map((e) => e == null
            ? null
            : JobListHolder.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'campaigns': instance.campaigns,
    };
