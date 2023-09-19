import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

part 'db_user_profile.g.dart';

@collection
class DbUserProfile {
  DbUserProfile(
      {required this.userId,
      required this.displayName,
      required this.photoUrl});
  String userId;
  Id get id => fastHash(userId);
  String displayName;
  String photoUrl;
}
