import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ReportedTimesheet.g.dart';

@JsonSerializable(nullable: true)
class ReportedTimesheet {
//  int jobID;
   String timein;
   String timeout;


  ReportedTimesheet({
//    this.jobID,
    this.timein,
    this.timeout,
  });

  factory ReportedTimesheet.fromJson(Map<String, dynamic> json) =>
      _$ReportedTimesheetFromJson(json);

  Map<String, dynamic> toJson() => _$ReportedTimesheetToJson(this);
}
