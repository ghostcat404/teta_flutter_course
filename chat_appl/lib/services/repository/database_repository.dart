import 'dart:core';

import 'package:chat_appl/models/db_models/db_user_chat.dart';
import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';

class DatabaseRepository {
  DatabaseRepository(
      {required this.localDbInstance,
      required this.dbInstance,
      required this.connectionIsAvailableFlg});

  final FirebaseDatabaseService dbInstance;
  final LocalDatabaseService localDbInstance;
  final bool connectionIsAvailableFlg;

  Future clearAllCache() async {
    await localDbInstance.clearAllCache();
  }

  Future cacheModel<T, E>(T? model) async {
    if (model != null) localDbInstance.cacheItem<T, E>(model);
  }

  Future cacheListModels<T, E>(List<T?> models) async {
    for (T? model in models) {
      cacheModel<T, E>(model);
    }
  }

  Future<T?> getModelByIdOrRef<T, E>(String modelId, String ref) async {
    final T? cachedModel = await localDbInstance.getModelById<T, E>(modelId);
    if (connectionIsAvailableFlg) {
      final T? model = await dbInstance.getModelByRef<T>(ref);
      if (cachedModel == null) {
        cacheModel<T, E>(model);
      }
      return model;
    }
    return cachedModel;
  }

  Future addOrUpdateModelByRef<T>(String ref, T model) async {
    if (connectionIsAvailableFlg) {
      await dbInstance.addOrUpdateModelByRef(model, ref);
    }
  }

  Future<List<T?>> getListOfModels<T, E>(String ref) async {
    if (connectionIsAvailableFlg) {
      final List<T?> models = await dbInstance.getModelsListByRef<T>(ref);
      cacheListModels<T, E>(models);
      return models;
    }
    return await localDbInstance.getListOfModelsByIndexId<T, E>();
  }

  Stream<List<T?>> getStreamOfListOfModels<T, E>(String ref,
      {String? indexId}) {
    if (connectionIsAvailableFlg) {
      final Stream<List<T?>> modelsStream =
          dbInstance.getStreamOfListOfModelsByRef<T>(ref);
      final Stream<List<T?>> chachedModelsStream =
          modelsStream.map((List<T?> models) {
        cacheListModels<T, E>(models);
        return models;
      });
      return chachedModelsStream;
    }
    return Stream<List<T?>>.fromFuture(
        localDbInstance.getListOfModelsByIndexId<T, E>(indexId: indexId));
  }

  Future createChatWithUser(
      String currUserId, String contactId, UserProfile contact) async {
    if (connectionIsAvailableFlg) {
      dbInstance.createChatWithUser(currUserId, contact);
    }
  }

  Future createOrUpdateUserContact(
      String userId, String contactId, UserProfile? contact) async {
    if (connectionIsAvailableFlg) {
      await dbInstance.addOrUpdateModelByRef(
          contact, 'userContacts/$userId/$contactId');
    }
  }

  Future updateUserSettings(UserSettings userSettings) async {
    if (connectionIsAvailableFlg) {
      await addOrUpdateModelByRef<UserSettings>(
          'userSettings/${userSettings.userId}', userSettings);
      final String profileRef = 'userProfiles/${userSettings.userId}';
      final UserProfile? currUserProfile =
          await getModelByIdOrRef<UserProfile, DbUserProfile>(
              userSettings.userId, profileRef);
      final UserProfile newUserProfile = currUserProfile!.copyWith(
          displayName: userSettings.displayName,
          photoUrl: userSettings.photoUrl);
      await addOrUpdateModelByRef<UserProfile>(
          'userProfiles/${userSettings.userId}', newUserProfile);
    }
  }

  Future sendMessage(
      String text, String userId, String chatId, String contactId) async {
    if (connectionIsAvailableFlg) {
      final String profileRef = 'userProfiles/$userId';
      final UserProfile? userProfile =
          await getModelByIdOrRef<UserProfile, DbUserProfile>(
              userId, profileRef);

      await dbInstance.sendMessage(text, userProfile!, chatId, contactId);
    }
  }

  Future clearChat(String currUserId, UserChat userChat) async {
    if (connectionIsAvailableFlg) {
      await dbInstance.addOrUpdateModelByRef(
          null, 'userChatsMessages/$currUserId/${userChat.chatId}/messages');
      await dbInstance.addOrUpdateModelByRef(
          userChat.copyWith(lastMessage: '', lastMessageTimestamp: null),
          'userChats/$currUserId/${userChat.chatId}');
    }
  }

  Future deleteChat(String currUserId, UserChat userChat) async {
    if (connectionIsAvailableFlg) {
      await clearChat(currUserId, userChat);
      await dbInstance.addOrUpdateModelByRef(
          null, 'userChats/$currUserId/${userChat.chatId}');
    }
  }

  Future<UserChat?> getOrCreateChatByContactId(
      String currUserId, String contactId) async {
    final String userChatRef = 'userChats/$currUserId/$contactId';
    UserChat? userChat =
        await getModelByIdOrRef<UserChat, DbUserChat>(currUserId, userChatRef);
    if (userChat != null) {
      return userChat;
    } else {
      if (connectionIsAvailableFlg) {
        final UserProfile? contact =
            await getModelByIdOrRef<UserProfile, DbUserProfile>(
                contactId, 'userProfiles/$contactId');
        createChatWithUser(currUserId, contactId, contact!);
        return await getModelByIdOrRef<UserChat, DbUserChat>(
            currUserId, userChatRef);
      }
    }
    return null;
  }
}
