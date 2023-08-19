import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

part 'db_user_settings.g.dart';

@collection
class DbUserSettings {
  DbUserSettings(
      {required this.userId,
      required this.displayName,
      required this.photoUrl,
      this.isNameEditing = false});
  String userId;
  Id get id => fastHash(userId);
  String displayName;
  String photoUrl;
  bool isNameEditing;
}
