import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'Conversation.g.dart';
@JsonSerializable(nullable: true)
class Conversation {
//  int jobID;
  final String updated_at;
  final String unread_count;
  final String last_sender_id;
  final String user_id;
  final String notify_status;
  final String last_message;
  final String updated_at_unix;
  final String user_id_status;
  final String picture;
  final String name;
  final String chat_key;




  Conversation({
    this.updated_at,
    this.unread_count,
    this.last_sender_id,
    this.user_id,
    this.notify_status,
    this.last_message,
    this.updated_at_unix,
    this.user_id_status,
    this.picture,
    this.name,
    this.chat_key
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);



}
