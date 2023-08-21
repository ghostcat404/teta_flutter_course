import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/services/fb_store_services/firebase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
String? authStateChanges(AuthStateChangesRef ref) {
  // TODO: add check for authentification everywhere!!!
  return ref.watch(firebaseAuthProvider).currentUser?.uid;
}

@riverpod
FirebaseDatabase firebaseDatabase(FirebaseDatabaseRef ref,
    {required FirebaseApp firebaseApp}) {
  return FirebaseDatabase.instanceFor(app: firebaseApp);
}

@riverpod
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

@riverpod
FirebaseDatabaseService? firebaseDbService(FirebaseDbServiceRef ref) {
  final String? userId = ref.watch(authStateChangesProvider);
  if (userId != null) {
    final FirebaseDatabase dbInstance = ref.watch(
        firebaseDatabaseProvider(firebaseApp: GetIt.instance<FirebaseApp>()));
    return FirebaseDatabaseService(dbInstance);
  }
  return null;
}

@riverpod
FirebaseStorageService? firebaseStorageService(FirebaseStorageServiceRef ref) {
  final String? userId = ref.watch(authStateChangesProvider);
  if (userId != null) {
    final FirebaseStorage storageInstance = ref.watch(firebaseStorageProvider);
    return FirebaseStorageService(storageInstance);
  }
  return null;
}

@riverpod
FirebaseMessaging firebaseMessaging(FirebaseMessagingRef ref) {
  return FirebaseMessaging.instance;
}

// @riverpod
// NotificationSettings notificationSettings(NotificationSettingsRef ref) {
//   return ;
// }

  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  // NotificationSettings notificationSettings = await firebaseMessaging
  //     .requestPermission(alert: true, badge: true, sound: true);
  // if (notificationSettings.authorizationStatus ==
  //     AuthorizationStatus.authorized) {
  //   print('User granted permission');
  // } else {
  //   print('User declined or has not accepted permission');
  // }
  // final fcmToken = await firebaseMessaging.getToken();
  // print('fcmToken: $fcmToken');
