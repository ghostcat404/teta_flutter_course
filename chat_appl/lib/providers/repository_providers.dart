import 'package:chat_appl/providers/db_providers.dart';
import 'package:chat_appl/providers/firebase_providers.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

@riverpod
Future<DatabaseRepository?> dbRepository(DbRepositoryRef ref) async {
  final FirebaseDatabaseService? firebaseDbService =
      ref.watch(firebaseDbServiceProvider);
  final LocalDatabaseService localDbService = ref.watch(localDbServiceProvider);
  return DatabaseRepository(
      localDbInstance: localDbService, dbInstance: firebaseDbService!);
}
