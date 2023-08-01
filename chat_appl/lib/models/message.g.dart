// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Message _$$_MessageFromJson(Map<String, dynamic> json) => _$_Message(
      userDisplayName: json['userDisplayName'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] as int,
    );

Map<String, dynamic> _$$_MessageToJson(_$_Message instance) =>
    <String, dynamic>{
      'userDisplayName': instance.userDisplayName,
      'text': instance.text,
      'timestamp': instance.timestamp,
    };
