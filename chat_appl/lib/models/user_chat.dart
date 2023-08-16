import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_chat.freezed.dart';
part 'user_chat.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class UserChat with _$UserChat {
  const factory UserChat({
    required String chatId,
    required String chatName,
    required String chatPhotoUrl,
    required String lastMessage,
    required String contactId,
    required int? lastMessageTimestamp,
  }) = _UserChat;

  factory UserChat.fromJson(Map<String, dynamic> json) =>
      _$UserChatFromJson(json);
}
