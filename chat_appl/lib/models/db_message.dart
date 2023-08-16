import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

part 'db_message.g.dart';

@collection
class DbMessage {
  DbMessage(
      {required this.messageId,
      required this.text,
      required this.timestamp,
      required this.userDisplayName,
      required this.senderId});
  String messageId;
  Id get id => fastHash(messageId);
  String userDisplayName;
  String text;
  String senderId;
  int timestamp;
}
