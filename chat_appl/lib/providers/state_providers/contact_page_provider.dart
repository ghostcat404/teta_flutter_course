import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contact_page_provider.g.dart';

@riverpod
class ContactPageState extends _$ContactPageState {
  Future _fetchProfile(String contactId) async {
    state = null;
    final UserProfile? profile = await ref
        .watch(dbRepositoryProvider)
        .getModelByIdOrRef<UserProfile, DbUserProfile>(
            contactId, 'userProfiles/$contactId');
    state = profile;
  }

  @override
  UserProfile? build(String contactId) {
    Future(() => _fetchProfile(contactId));
    return null;
  }
}
