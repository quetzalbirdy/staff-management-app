import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'PendingShift.g.dart';
@JsonSerializable(nullable: true)
class PendingShift {
  final int company_id;
  final int id;
  final String address;
  final String status;
  final String access;
  final int open;
  final double latitude;
  final double longitude;
  final String start;
  final String end;
  final String post_instruction;
  bool isCheck;
  final String contact_name;
  final String contact_number;



  PendingShift({
//    this.jobID,
    @required this.company_id,
    @required this.id,
    @required this.address,
    @required this.status,
    this.access,
    this.open,
//    this.due,
    this.latitude,
    this.longitude,
    this.start,
    this.end,
    this.isCheck,
    this.contact_name,
    this.contact_number,
    this.post_instruction,
  });

  factory PendingShift.fromJson(Map<String, dynamic> json) => _$PendingShiftFromJson(json);

  Map<String, dynamic> toJson() => _$PendingShiftToJson(this);



}