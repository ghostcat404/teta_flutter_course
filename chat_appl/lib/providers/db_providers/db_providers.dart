import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db_providers.g.dart';

@riverpod
LocalDatabaseService localDbService(LocalDbServiceRef ref) {
  return LocalDatabaseService(GetIt.instance<Isar>());
}
