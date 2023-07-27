import 'package:isar/isar.dart';

part 'db_user.g.dart';

@collection
class DbUser {
  Id id = Isar.autoIncrement;
  String? userId;
  String? displayName;
  String? photoUrl;
}