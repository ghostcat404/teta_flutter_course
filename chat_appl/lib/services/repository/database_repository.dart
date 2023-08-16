import 'package:chat_appl/models/user_chat.dart';
import 'package:chat_appl/models/user_contact.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';

class DatabaseRepository {
  DatabaseRepository({required this.localDbInstance, required this.dbInstance});

  final FirebaseDatabaseService dbInstance;
  final LocalDatabaseService localDbInstance;

  Stream<List<UserContact?>> getContactsStream(
      String userId, bool connectionIsAvailableFlg) {
    if (connectionIsAvailableFlg) return dbInstance.getContactsStream(userId);
    return Stream.fromFuture(localDbInstance.getUserContacts());
  }

  Stream<List<UserChat?>> getUserChatsStream(
      String userId, bool connectionIsAvailableFlg) {
    if (connectionIsAvailableFlg) return dbInstance.getUserChatsStream(userId);
    return Stream.fromFuture(localDbInstance.getUserChats());
  }
}
