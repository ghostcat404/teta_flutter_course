import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_contact.freezed.dart';
part 'user_contact.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class UserContact with _$UserContact {
  const factory UserContact({
    required String contactId,
    required String displayName,
    required String photoUrl,
  }) = _UserContact;

  factory UserContact.fromJson(Map<String, dynamic> json) =>
      _$UserContactFromJson(json);
}
