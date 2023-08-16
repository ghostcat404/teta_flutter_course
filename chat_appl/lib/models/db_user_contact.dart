import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

part 'db_user_contact.g.dart';

@collection
class DbUserContact {
  DbUserContact({
    required this.contactId,
    required this.displayName,
    required this.photoUrl,
  });
  String contactId;
  String displayName;
  String photoUrl;
  Id get id => fastHash(contactId);
}
