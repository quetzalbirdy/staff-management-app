import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wolf_jobs/model/JobListHolder.dart';

part 'jobList.g.dart';
@JsonSerializable(nullable: true)
  class Job {
//  final int company_id;
//  final int id;
//  final String notes;
//  final String title;

  List <JobListHolder> campaigns;

  Job({
//    @required this.company_id,
//    @required this.id,
//    @required this.notes,
//    @required this.title,
      this.campaigns
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);

//
//  factory Post.fromJson(Map<String, dynamic> json) {
//    return Post(
//      company_id: json['company_id'] as int,
//      id: json['id'] as int,
//      notes: json['notes'] as String,
//      title: json['title'] as String,
//    );
//  }

}