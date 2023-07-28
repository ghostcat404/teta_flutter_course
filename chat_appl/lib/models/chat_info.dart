import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_info.freezed.dart';
part 'chat_info.g.dart';

@freezed
class ChatInfo with _$ChatInfo {
  const factory ChatInfo({
    required String chatId,
    required String userBId,
    required String lastMessage,
  }) = _ChatInfo;

  factory ChatInfo.fromJson(Map<String, dynamic> json) => _$ChatInfoFromJson(json);
}