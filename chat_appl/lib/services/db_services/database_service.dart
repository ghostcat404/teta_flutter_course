import 'dart:core';

import 'package:chat_appl/models/db_models/db_message.dart';
import 'package:chat_appl/models/db_models/db_user_chat.dart';
import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/services/db_services/services_utils.dart';
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
    await isarDbInstance.writeTxn(
        () async => await isarDbInstance.collection<DbUserProfile>().clear());
  }

  Future cacheItem<E, T>(E item) async {
    final T convertedItem = convertModelGetter<E, T>(item) as T;
    await isarDbInstance.writeTxn(
        () async => await isarDbInstance.collection<T>().put(convertedItem));
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

  Future<List<T?>> getListOfModelsByIndexId<T, E>({String? indexId}) async {
    final List<dynamic> dbModels = await isarDbInstance.txn(() async {
      if (indexId != null) {
        return await isarDbInstance.collection<E>().buildQuery(whereClauses: [
          IndexWhereClause.equalTo(indexName: 'indexId', value: [indexId])
        ]).findAll();
      }
      return await isarDbInstance.collection<E>().where().findAll();
    });
    final List<T?> models = [];
    if (dbModels.isNotEmpty) {
      for (E? dbModel in dbModels) {
        models.add(convertModelGetter<E, T>(dbModel as E));
      }
    }
    sortInstancesOf<T>(models);
    return models;
  }

  Future<List<Message?>> getListOfMessageByChatId(String chatId) async {
    final List<DbMessage?> dbModels = await isarDbInstance.txn(() async {
      return isarDbInstance
          .collection<DbMessage>()
          .filter()
          .chatIdEqualTo(chatId)
          .findAll();
    });

    final List<Message?> models = [];
    if (dbModels.isNotEmpty) {
      for (DbMessage? dbModel in dbModels) {
        models.add(convertModelGetter<DbMessage, Message>(dbModel!));
      }
    }
    return models;
  }
}
