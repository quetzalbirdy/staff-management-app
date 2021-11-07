import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Message.g.dart';
@JsonSerializable(nullable: true)
class Message {
//  int jobID;
  final String content;
  final String created_at;
  final String unique_interaction_locator;
  final String ttl;
  final bool response_status;
  final String chat_key;
  final String sender_id;
  final String tenant;
  final bool response_required;
  final String content_type;
  final String notification_master_category;
  final String notification_sub_category;
  final String body;




  Message({
    this.content,
    this.created_at,
    this.unique_interaction_locator,
    this.ttl,
    this.response_status,
    this.chat_key,
    this.sender_id,
    this.tenant,
    this.response_required,
    this.content_type,
    this.notification_master_category,
    this.notification_sub_category,
    this.body  
   });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);



}
