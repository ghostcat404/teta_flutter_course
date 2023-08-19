import 'dart:core';

import 'package:chat_appl/models/db_models/db_message.dart';
import 'package:chat_appl/models/db_models/db_user_chat.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/services/mappers/model_convertation_mappers.dart';
import 'package:chat_appl/utils/utils.dart';
import 'package:isar/isar.dart';

class LocalDatabaseService {
  LocalDatabaseService(this.isarDbInstance);

  final Isar isarDbInstance;

  Future clearAllCache() async {
    await isarDbInstance.writeTxn(
        () async => await isarDbInstance.collection<DbUserChat>().clear());
    await isarDbInstance.writeTxn(
        () async => await isarDbInstance.collection<DbMessage>().clear());
  }

  Future cacheItem<E, T>(E item) async {
    await isarDbInstance.writeTxn(() async => await isarDbInstance
        .collection<T>()
        .put(convertModelGetter<E, T>(item) as T));
  }

  Future deleteCachedItemById<T>(String itemId) async {
    await isarDbInstance.writeTxn(() async =>
        await isarDbInstance.collection<T>().delete(fastHash(itemId)));
  }

  Future<T?> getModelById<T, E>(String itemId) async {
    final E? dbItem =
        await isarDbInstance.collection<E>().get(fastHash(itemId));
    if (dbItem != null) {
      return convertModelGetter<E, T>(dbItem);
    }
    return null;
  }

  Future<List<T?>> getListOfModels<T, E>() async {
    final List<E?> dbModels = await isarDbInstance.txn(() async {
      return await isarDbInstance.collection<E>().where().findAll();
    });
    final List<T?> models = [];
    if (dbModels.isNotEmpty) {
      for (E? dbModel in dbModels) {
        models.add(convertModelGetter<E, T>(dbModel as E));
      }
    }
    return models;
  }

  Future<List<UserChat?>> getUserChats() async {
    final List<DbUserChat?> dbUserChats = await isarDbInstance.txn(() async {
      return await isarDbInstance.collection<DbUserChat>().where().findAll();
    });
    final List<UserChat?> userChats = [];
    if (dbUserChats.isNotEmpty) {
      for (DbUserChat? dbUserChat in dbUserChats) {
        userChats.add(convertModelGetter<DbUserChat, UserChat>(dbUserChat!));
      }
    }
    return userChats;
  }
}
