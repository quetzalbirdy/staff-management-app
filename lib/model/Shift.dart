import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Shift.g.dart';
@JsonSerializable(nullable: true)
class Shifts {
//  int jobID;
  final int company_id;
  final int id;
  final String address;
  final String status;
  final String access;
  final int open;
//  final String due;
  final double latitude;
  final double longitude;
  final String start;
  final String end;
  bool isCheck;
  final String contact_name;



  Shifts({
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
  });

  factory Shifts.fromJson(Map<String, dynamic> json) => _$ShiftsFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftsToJson(this);



}
