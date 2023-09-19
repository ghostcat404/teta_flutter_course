import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_info.freezed.dart';
part 'chat_info.g.dart';

@freezed
class ChatInfo with _$ChatInfo {
  const factory ChatInfo({
    required String chatId,
    required String lastMessage,
    int? lastMessageTimestamp,
  }) = _ChatInfo;

  factory ChatInfo.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoFromJson(json);
}
