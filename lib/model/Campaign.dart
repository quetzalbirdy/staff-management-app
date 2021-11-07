import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Campaign.g.dart';
@JsonSerializable(nullable: true)
class Campaign {
//  int jobID;
  final int company_id;
  final int id;
  final String notes;
  final String title;
  final String banner_image;
  final bool client_name;
  final String address_display;
  final String charge_rate;
  final String job_type;
  final String created_at;
  final String timesheets;
  final int radius;
  final String pay_rate;
  final String pay_rate_effective_date;

  Campaign({
//    this.jobID,
    @required this.company_id,
    @required this.id,
    @required this.notes,
    @required this.title,
    this.banner_image,
    this.client_name,
    this.address_display,
    this.charge_rate,
    this.job_type,
    this.created_at,
    this.timesheets,
    this.radius,
    this.pay_rate_effective_date,
    this.pay_rate
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);

  Map<String, dynamic> toJson() => _$CampaignToJson(this);



}
