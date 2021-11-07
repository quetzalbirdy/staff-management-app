import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Tender.g.dart';
@JsonSerializable(nullable: true)
class Tender {
  String availability_freshness;

  Tender({
//    this.jobID,
    this.availability_freshness
  });

  factory Tender.fromJson(Map<String, dynamic> json) => _$TenderFromJson(json);

  Map<String, dynamic> toJson() => _$TenderToJson(this);



}
