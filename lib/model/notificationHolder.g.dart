// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificationHolder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notiification _$NotiificationFromJson(Map<String, dynamic> json) {
  return Notiification(
    content: json['content'] as String,
    notification_master_category:
        json['notification_master_category'] as String,
    notification_sub_category: json['notification_sub_category'] as String,
    channel_type: json['channel_type'] as String,
    content_type: json['content_type'] as String,
    created_at: json['created_at'] as String,
    action_url: json['action_url'] as String,
    total: json['total'] as String,
    subject: json['subject'] as String,
    body: json['body'] as String,
    actionurl_btn: json['actionurl_btn'] as String,
  );
}

Map<String, dynamic> _$NotiificationToJson(Notiification instance) =>
    <String, dynamic>{
      'content': instance.content,
      'channel_type': instance.channel_type,
      'content_type': instance.content_type,
      'created_at': instance.created_at,
      'action_url': instance.action_url,
      'notification_master_category': instance.notification_master_category,
      'notification_sub_category': instance.notification_sub_category,
      'subject': instance.subject,
      'body': instance.body,
      'actionurl_btn': instance.actionurl_btn,
      'total': instance.total,
    };
