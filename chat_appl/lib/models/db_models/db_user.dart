import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

part 'db_user.g.dart';

@collection
class DbUser {
  DbUser(
      {required this.userId,
      required this.displayName,
      required this.photoUrl});
  String userId;
  Id get id => fastHash(userId);
  String displayName;
  String photoUrl;
}
