// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Message _$$_MessageFromJson(Map<String, dynamic> json) => _$_Message(
      messageId: json['messageId'] as String,
      userDisplayName: json['userDisplayName'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] as int,
      senderId: json['senderId'] as String,
    );

Map<String, dynamic> _$$_MessageToJson(_$_Message instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'userDisplayName': instance.userDisplayName,
      'text': instance.text,
      'timestamp': instance.timestamp,
      'senderId': instance.senderId,
    };
