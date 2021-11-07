import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wolf_jobs/model/Shift.dart';
part 'JobListHolder.g.dart';
@JsonSerializable(nullable: true)
class JobListHolder {
//  int jobID;
  final int company_id;
  final int id;
  final String notes;
  final String title;
  final String banner_image;
  final String client_name;
  final String address_display;
  final String charge_rate;
  final String job_type;
  final String created_at;
  final String timesheets;
  final int radius;
  final String pay_rate;
  final String pay_rate_effective_date;
  List <Shifts> shifts;



  JobListHolder({
//    this.jobID,
     this.company_id,
    this.id,
    this.notes,
    this.title,
    this.banner_image,
    this.client_name,
    this.address_display,
    this.charge_rate,
    this.job_type,
    this.created_at,
    this.timesheets,
    this.shifts,
    this.radius,
    this.pay_rate_effective_date,
    this.pay_rate
  });

  factory JobListHolder.fromJson(Map<String, dynamic> json) => _$JobListHolderFromJson(json);

  Map<String, dynamic> toJson() => _$JobListHolderToJson(this);

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