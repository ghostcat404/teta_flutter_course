import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String userId,
    required String text,
    required int timestamp
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => {'userId': userId, 'text': text, 'timestamp': timestamp};
  // factory Message.fromMap(Map<dynamic, dynamic> data) => _$MessageFromMap(data);
}