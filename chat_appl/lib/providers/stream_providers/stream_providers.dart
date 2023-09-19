import 'package:chat_appl/models/db_models/db_message.dart';
import 'package:chat_appl/models/db_models/db_user_chat.dart';
import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stream_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<ConnectivityResult> checkConnection(CheckConnectionRef ref) {
  return Connectivity().onConnectivityChanged;
}

@riverpod
Stream<List<UserProfile?>> contactsStream(ContactsStreamRef ref) {
  final String? currentUserId = ref.watch(authStateChangesProvider);
  return ref
      .watch(dbRepositoryProvider)
      .getStreamOfListOfModels<UserProfile, DbUserProfile>(
          'userContacts/${currentUserId!}');
}

@riverpod
Stream<List<UserChat?>> chatsStream(ChatsStreamRef ref) {
  final String? currentUserId = ref.watch(authStateChangesProvider);
  return ref
      .watch(dbRepositoryProvider)
      .getStreamOfListOfModels<UserChat, DbUserChat>(
          'userChats/${currentUserId!}');
}

@riverpod
Stream<List<UserProfile?>> profilesStream(ProfilesStreamRef ref) {
  return ref
      .watch(dbRepositoryProvider)
      .getStreamOfListOfModels<UserProfile, DbUserProfile>('userProfiles');
}

@riverpod
Stream<List<Message?>> messagesStream(MessagesStreamRef ref,
    {required String chatId}) {
  final String? currentUserId = ref.watch(authStateChangesProvider);
  return ref
      .watch(dbRepositoryProvider)
      .getStreamOfListOfModels<Message, DbMessage>(
          'userChatsMessages/$currentUserId/$chatId/messages',
          indexId: chatId);
}
