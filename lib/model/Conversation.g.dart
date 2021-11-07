// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return Conversation(
    updated_at: json['updated_at'] as String,
    unread_count: json['unread_count'] as String,
    last_sender_id: json['last_sender_id'] as String,
    user_id: json['user_id'] as String,
    notify_status: json['notify_status'] as String,
    last_message: json['last_message'] as String,
    updated_at_unix: json['updated_at_unix'] as String,
    user_id_status: json['user_id_status'] as String,
    picture: json['picture'] as String,
    name: json['name'] as String,
    chat_key: json['chat_key'] as String,
  );
}

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'updated_at': instance.updated_at,
      'unread_count': instance.unread_count,
      'last_sender_id': instance.last_sender_id,
      'user_id': instance.user_id,
      'notify_status': instance.notify_status,
      'last_message': instance.last_message,
      'updated_at_unix': instance.updated_at_unix,
      'user_id_status': instance.user_id_status,
      'picture': instance.picture,
      'name': instance.name,
      'chat_key': instance.chat_key,
    };
