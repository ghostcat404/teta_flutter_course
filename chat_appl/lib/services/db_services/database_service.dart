import 'package:chat_appl/models/db_user.dart';
import 'package:isar/isar.dart';

class LocalDatabaseService {
  final Isar isarDbInstance;
  LocalDatabaseService({required this.isarDbInstance});

  Future clearAllCache() async =>
      await isarDbInstance.writeTxn(() async => await isarDbInstance.clear());

  Future<List<DbUser?>> getAllUsers() async {
    final List<DbUser?> users = await isarDbInstance.txn(() async =>
        await isarDbInstance.collection<DbUser>().where().findAll());
    return users.toList();
  }
}
