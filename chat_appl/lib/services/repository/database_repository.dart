import 'dart:core';

import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_contact.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';

class DatabaseRepository {
  DatabaseRepository({required this.localDbInstance, required this.dbInstance});

  final FirebaseDatabaseService dbInstance;
  final LocalDatabaseService localDbInstance;

  Stream<List<UserContact?>> getContactsStream(
      String userId, bool connIsAvailableFlg) {
    if (connIsAvailableFlg) return dbInstance.getContactsStream(userId);
    return Stream.fromFuture(localDbInstance.getUserContacts());
  }

  Stream<List<UserChat?>> getUserChatsStream(
      String userId, bool connIsAvailableFlg) {
    if (connIsAvailableFlg) return dbInstance.getUserChatsStream(userId);
    return Stream.fromFuture(localDbInstance.getUserChats());
  }

  Future<List<UserChat?>> getChats(
      String userId, bool connIsAvailableFlg) async {
    if (connIsAvailableFlg) return await dbInstance.getUserChats(userId);
    return localDbInstance.getUserChats();
  }

  Future<List<UserContact?>> getContacts(
      String userId, bool connIsAvailableFlg) async {
    if (connIsAvailableFlg) return await dbInstance.getUserContacts(userId);
    return localDbInstance.getUserContacts();
  }

  Future<UserProfile?> getUserProfile(
      String userId, bool connIsAvailableFlg) async {
    if (connIsAvailableFlg) return await dbInstance.getUserProfile(userId);
    return localDbInstance.getUserProfile(userId);
  }

  Future cacheInstance<T>() async {}
  Future sortInstance<T>() async {}
  Future getInstance<T>() async {}
}
