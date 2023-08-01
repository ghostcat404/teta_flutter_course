import 'package:chat_appl/models/user.dart';

User? convertor(dynamic other) {
  return User(
      id: other.userId,
      displayName: other.displayName,
      photoUrl: other.photoUrl);
}
