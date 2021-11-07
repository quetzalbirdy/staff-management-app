import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'TimeSheet.g.dart';
@JsonSerializable(nullable: true)
class TimeSheet {
//  int jobID;
  final String updated_at;
  final String timein;
  final String freelancer_id;
  final String created_at;
  final String address;
  final String end;
//  final String due;
  final String tender_id;
  final String id;
  final String start;
  final String campaign_id;
  final String shift_id;
  final String authorizer_code;
  final bool charged;
  final String total_pay;
  final String pay_status;
  final String hours;
  final String income_id;
  final String billing;
  final String timeout;
  final String hour_status;
  final String chargable;
  final String notes;
  final String authorizer;
  final String job_type;



  TimeSheet({
//    this.jobID,
    this.updated_at,
    this.timein,
    this.freelancer_id,
    this.created_at,
    this.address,
    this.end,
//   this.due,
    this.tender_id,
    this.id,
    this.start,
    this.campaign_id,
    this.shift_id,
    this.authorizer_code,
    this.charged,
    this.total_pay,
    this.pay_status,
    this.hours,
    this.income_id,
    this.billing,
    this.timeout,
    this.hour_status,
    this.chargable,
    this.notes,
    this.authorizer,
    this.job_type

  });

  factory TimeSheet.fromJson(Map<String, dynamic> json) => _$TimeSheetFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSheetToJson(this);



}