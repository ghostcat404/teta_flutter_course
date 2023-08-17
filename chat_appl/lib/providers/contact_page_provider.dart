import 'package:chat_appl/models/fb_models/user_contact.dart';
import 'package:chat_appl/providers/default_providers.dart';
import 'package:chat_appl/providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers.dart';
// import 'package:chat_appl/models/fb_models/user_settings.dart';
// import 'package:chat_appl/providers/repository_providers.dart';
// import 'package:chat_appl/providers/user_profile_provider.dart';
// import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contact_page_provider.g.dart';

// @riverpod
// Stream<List<UserContact>?> userContactsStream(UserContactsStreamRef ref) {
//   final DatabaseRepository? dbRepository = ref.watch(dbRepositoryProvider);
//   // final UserSettings userSettings = ref.watch(userProfileNotifierProvider.)
//   // return dbRepository.getContactsStream(userProfileNotifierProvider, connectionIsAvailableFlg);
// }

@riverpod
class ContactPageState extends _$ContactPageState {
  Future<List<UserContact?>> _fetchUserContacts() async {
    final String? currUserId =
        ref.watch(authStateChangesProvider.select((value) => value));
    bool connectionIsAvailableFlg =
        await ref.watch(connectionStateProvider.future);
    return (await ref.read(dbRepositoryProvider.future))!
        .getContacts(currUserId!, connectionIsAvailableFlg);
  }

  @override
  Future<List<UserContact?>> build() async {
    return _fetchUserContacts();
  }

  // @override
  // ContactPageState.listen<>(, (previous, next) {

  // });
}
