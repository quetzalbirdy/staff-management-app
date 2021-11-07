// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    content: json['content'] as String,
    created_at: json['created_at'] as String,
    unique_interaction_locator: json['unique_interaction_locator'] as String,
    ttl: json['ttl'] as String,
    response_status: json['response_status'] as bool,
    chat_key: json['chat_key'] as String,
    sender_id: json['sender_id'] as String,
    tenant: json['tenant'] as String,
    response_required: json['response_required'] as bool,
    content_type: json['content_type'] as String,
    notification_master_category:
        json['notification_master_category'] as String,
    notification_sub_category: json['notification_sub_category'] as String,
    body: json['body'] as String,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'content': instance.content,
      'created_at': instance.created_at,
      'unique_interaction_locator': instance.unique_interaction_locator,
      'ttl': instance.ttl,
      'response_status': instance.response_status,
      'chat_key': instance.chat_key,
      'sender_id': instance.sender_id,
      'tenant': instance.tenant,
      'response_required': instance.response_required,
      'content_type': instance.content_type,
      'notification_master_category': instance.notification_master_category,
      'notification_sub_category': instance.notification_sub_category,
      'body': instance.body,
    };
