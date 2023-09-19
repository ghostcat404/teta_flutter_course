import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

part 'db_user_chat.g.dart';

@collection
class DbUserChat {
  DbUserChat({
    required this.chatId,
    required this.chatName,
    required this.chatPhotoUrl,
    required this.lastMessage,
    required this.contactId,
    required this.lastMessageTimestamp,
  });
  String chatId;
  String chatName;
  String chatPhotoUrl;
  String lastMessage;
  String contactId;
  int? lastMessageTimestamp;
  Id get id => fastHash(chatId);
}
