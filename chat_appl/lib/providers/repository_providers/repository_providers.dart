import 'package:chat_appl/providers/db_providers/db_providers.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/stream_providers/stream_providers.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_providers.g.dart';

@riverpod
DatabaseRepository dbRepository(DbRepositoryRef ref) {
  final FirebaseDatabaseService? firebaseDbService =
      ref.watch(firebaseDbServiceProvider);
  final LocalDatabaseService localDbService = ref.watch(localDbServiceProvider);
  final connectivityStream = ref.watch(checkConnectionProvider);
  bool? conn = connectivityStream
      .whenData(
          (connResult) => connResult == ConnectivityResult.none ? false : true)
      .asData
      ?.value;
  conn ??= false;
  return DatabaseRepository(
      localDbInstance: localDbService,
      dbInstance: firebaseDbService!,
      connectionIsAvailableFlg: conn);
}
