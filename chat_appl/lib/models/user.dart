import 'package:chat_appl/models/chat_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class User with _$User {
  const factory User({
    required String id,
    required String displayName,
    required String photoUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}