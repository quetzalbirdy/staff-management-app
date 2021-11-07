import 'package:wolf_jobs/model/Campaign.dart';
import 'package:wolf_jobs/model/ReportedTimesheet.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wolf_jobs/model/Tender.dart';
part 'ShiftListHolder.g.dart';
@JsonSerializable(nullable: true)
class ShiftListHolder {
//  int jobID;
  final int company_id;
  final int id;
  final String address;
  final String status;
  final String access;
  final int open;
  final String due;
  final double latitude;
  final double longitude;
  final String start;
  final String end;
  final String created_at;
//  bool isCheck;
  final String contact_name;
  final String contact_number;
  final String price;
  final String client_name;
  final String job_type;
  final String banner_image;
  final String post_instruction;
  final int position;
  bool isCheckIn;
  Campaign campaign;
  ReportedTimesheet reported_timesheet;
  Tender tender;



  ShiftListHolder({
//    this.jobID,
    @required this.company_id,
    @required this.id,
    @required this.address,
    @required this.status,
    this.access,
    this.open,
    this.due,
    this.latitude,
    this.longitude,
    this.start,
    this.end,
//    this.isCheck,
    this.contact_name,
    this.price,
    this.client_name,
    this.job_type,
    this.banner_image,
    this.post_instruction,
    this.position,
    this.campaign,    
    this.created_at,
    this.isCheckIn,
    this.contact_number,
    this.reported_timesheet,
    this.tender
  });

  factory ShiftListHolder.fromJson(Map<String, dynamic> json) => _$ShiftListHolderFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftListHolderToJson(this);



}
