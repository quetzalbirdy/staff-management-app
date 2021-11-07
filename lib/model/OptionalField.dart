import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'OptionalField.g.dart';
@JsonSerializable(nullable: true)
class OptionalField {
//  int jobID;
  final int optionString;



  OptionalField({
//    this.jobID,
     this.optionString,
  });

  factory OptionalField.fromJson(Map<String, dynamic> json) => _$OptionalFieldFromJson(json);

  Map<String, dynamic> toJson() => _$OptionalFieldToJson(this);



}