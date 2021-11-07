import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
part 'notificationHolder.g.dart';
@JsonSerializable(nullable: true)
class Notiification {
  final String content;
  final String channel_type;
  final String content_type;
  final String created_at;
  final String action_url;
  final String notification_master_category;
  final String notification_sub_category;
  final String subject;
  final String body;
  final String actionurl_btn;
  final String total;
  Notiification({this.content, this.notification_master_category, this.notification_sub_category, this.channel_type, this.content_type, this.created_at, this.action_url, this.total,this.subject,this.body,this.actionurl_btn});

  factory Notiification.fromJson(Map<String, dynamic> json) => _$NotiificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotiificationToJson(this);
}
