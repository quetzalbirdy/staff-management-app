import 'package:wolf_jobs/model/Campaign.dart';
import 'package:wolf_jobs/model/PendingShift.dart';
import 'package:wolf_jobs/model/ReportedTimesheet.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'PendingShiftsHolder.g.dart';
@JsonSerializable(nullable: true)
class PendingShiftsHolder {
  final String tender_status;  
  final String start;
  final String end;
  final String address;
  final String title;
  final String client;
  final String price;
  final String notes;
  final int tender_id;
  final int shift_id;
  final int campaign_id;
  PendingShift shift;
  bool is_full;                                  

  PendingShiftsHolder({
//    this.jobID,    
    this.tender_id,
    this.tender_status,
    this.price,   
    this.start,
    this.end,      
    this.address,    
    this.title,   
    this.client,
    this.notes,
    this.campaign_id,
    this.shift,
    this.shift_id,
    this.is_full  
  });

  factory PendingShiftsHolder.fromJson(Map<String, dynamic> json) => _$PendingShiftsHolderFromJson(json);

  Map<String, dynamic> toJson() => _$PendingShiftsHolderToJson(this);



}