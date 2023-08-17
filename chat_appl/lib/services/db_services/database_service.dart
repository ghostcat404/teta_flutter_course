import 'dart:core';

import 'package:chat_appl/models/db_models/db_message.dart';
import 'package:chat_appl/models/db_models/db_user.dart';
import 'package:chat_appl/models/db_models/db_user_chat.dart';
import 'package:chat_appl/models/db_models/db_user_contact.dart';
import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_contact.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/services/mappers/model_convertation_mappers.dart';
import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

class LocalDatabaseService {
  LocalDatabaseService(this.isarDbInstance);

  final Isar isarDbInstance;

  Future clearAllCache() async =>
      await isarDbInstance.writeTxn(() async => await isarDbInstance.clear());

  Future<UserProfile?> getUserProfile(String userId) async {
    final DbUserProfile? dbUserProfile =
        await isarDbInstance.collection<DbUserProfile>().get(fastHash(userId));
    if (dbUserProfile != null) {
      return toUserProfileFromDbUserProfile(dbUserProfile);
    }
    return null;
  }

  Future<List<DbUser?>> getAllUsers() async {
    final List<DbUser?> users = await isarDbInstance.txn(() async =>
        await isarDbInstance.collection<DbUser>().where().findAll());
    return users.toList();
  }

  Future<List<UserContact?>> getUserContacts() async {
    final List<DbUserContact?> dbUserContacts =
        await isarDbInstance.txn(() async {
      return await isarDbInstance.collection<DbUserContact>().where().findAll();
    });
    final List<UserContact?> userContacts = [];
    if (dbUserContacts.isNotEmpty) {
      for (DbUserContact? dbUserContact in dbUserContacts) {
        userContacts.add(toUserContactFromDbUserContact(dbUserContact!));
      }
    }
    return userContacts;
  }

  Future<List<UserChat?>> getUserChats() async {
    final List<DbUserChat?> dbUserChats = await isarDbInstance.txn(() async {
      return await isarDbInstance.collection<DbUserChat>().where().findAll();
    });
    final List<UserChat?> userChats = [];
    if (dbUserChats.isNotEmpty) {
      for (DbUserChat? dbUserChat in dbUserChats) {
        userChats.add(toUserChatFromDbUserChat(dbUserChat!));
      }
    }
    return userChats;
  }

  Future<UserContact?> getUserContactById(String contactId) async {
    final DbUserContact? dbUserContact = await isarDbInstance.txn(() async =>
        await isarDbInstance
            .collection<DbUserContact>()
            .get(fastHash(contactId)));
    if (dbUserContact != null) {
      return toUserContactFromDbUserContact(dbUserContact);
    }
    return null;
  }

  Future<UserChat?> getUserChatById(String chatId) async {
    final DbUserChat? dbUserChat = await isarDbInstance.txn(() async =>
        await isarDbInstance.collection<DbUserChat>().get(fastHash(chatId)));
    if (dbUserChat != null) {
      return toUserChatFromDbUserChat(dbUserChat);
    }
    return null;
  }

  Future<User?> getUserById(String userId) async {
    final int dbUserId = fastHash(userId);
    final DbUser? dbUser =
        await isarDbInstance.collection<DbUser>().get(dbUserId);
    if (dbUser != null) {
      return toUserFromDbUser(dbUser);
    }
    return null;
  }

  Future cacheUserContact(UserContact userContact) async {
    await isarDbInstance.writeTxn(() async => await isarDbInstance
        .collection<DbUserContact>()
        .put(toDbUserContactFromUserContact(userContact)));
  }

  Future cacheUserChat(UserChat userChat) async {
    await isarDbInstance.writeTxn(() async => await isarDbInstance
        .collection<DbUserChat>()
        .put(toDbUserChatFromUserChat(userChat)));
  }

  // TODO: move logic in DatabaseRepository
  Future cacheMessage(Message message) async {
    await isarDbInstance.writeTxn(() async => await isarDbInstance
        .collection<DbMessage>()
        .put(toDbMessageFromMessage(message)));
  }
}
