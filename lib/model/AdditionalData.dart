import 'package:wolf_jobs/model/OptionalField.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'AdditionalData.g.dart';
@JsonSerializable(nullable: true)
class AdditionalData {
//  int jobID;
  final int custom_requirement_id;
  final String question;
  final String field_type;
  final String units;
  final String required_level;
  final String description;
  final String value;
  List <String> options;
  bool isCheck;


  AdditionalData({
//    this.jobID,
    @required this.custom_requirement_id,
    @required this.question,
    @required this.field_type,
    @required this.units,
    this.required_level,
    this.description,
    this.value,
    this.options,
    this.isCheck


  });

  factory AdditionalData.fromJson(Map<String, dynamic> json) => _$AdditionalDataFromJson(json);

  Map<String, dynamic> toJson() => _$AdditionalDataToJson(this);



}