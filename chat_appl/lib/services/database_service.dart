import 'package:isar/isar.dart';

class LocalDatabaseService {
  final Isar isarDbInstance;
  LocalDatabaseService({required this.isarDbInstance});

  Future clearAllCache() async =>
      await isarDbInstance.writeTxn(() async => await isarDbInstance.clear());
}
