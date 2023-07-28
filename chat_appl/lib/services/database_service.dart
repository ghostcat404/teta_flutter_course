import 'package:chat_appl/models/db_user.dart';
import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

class DatabaseService {
  final FirebaseDatabase dbInstance;

  DatabaseService({required this.dbInstance});

  Future<List<User>> getUsers() async {
    return [];
  }

  Future addOrUpdateUserInfo(User user) async {
    DatabaseReference ref = dbInstance.ref("users/${user.id}");
    await ref.set({
      'id': user.id,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
    });
  }

  Future<String> getUserName(String userId) async {
    final DataSnapshot dataSnapshot = await dbInstance
      .ref()
      .child('users')
      .child(userId)
      .child('displayName')
      .get();
    return dataSnapshot.value. toString();
  }

  Future<User?> getUser(String userId) async {
    final userSnapshot = await dbInstance
      .ref()
      .child('users/$userId')
      .get();
    if (userSnapshot.value != null) {
      final currentUser = Map<String, dynamic>.from(userSnapshot.value as Map) ;
      final user = User(
        id: userId,
        displayName: currentUser['displayName'],
        photoUrl: currentUser['photoUrl']
      );
      return user;
    }
    return null;
  }

  Future updateUserDisplayName(String displayName) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final userId = firebaseUser.uid;
      final photoURL = firebaseUser.photoURL ?? '';
      final user = User(
        id: userId,
        displayName: displayName,
        photoUrl: photoURL
      );
      await addOrUpdateUserInfo(user);
    }
  }

  Future sendMessage(String text, String uuid) async {
    final DatabaseReference dbRef = dbInstance.ref('messages'); 
    final message = Message(
      userId: uuid,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch
    );
    final messageRef = dbRef.push();
    await messageRef.set(message.toJson());
  }

  Stream<List<Message?>> get messageStream => _getStreamByRef<Message>('messages');

  Stream<List<User?>> get contactsStream => _getStreamByRef<User>('users');

  Stream<List<T?>> _getStreamByRef<T>(String refName) {
    return dbInstance.ref(refName).onValue.map((event) {
      List<T?> dataList = [];
      if (event.snapshot.value != null) {
        final firebaseMessages = Map<dynamic, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
        firebaseMessages.forEach((key, value) {
          final currentData = Map<String, dynamic>.from(value);
          final T? instance = createInstanceOf<T>(currentData);
          if (instance != null) cacheInstanceOf<T>(instance);
          dataList.add(instance);
        });
      }
      return dataList;
    });
  }
}

T? createInstanceOf<T>(Map<String, dynamic> json) {
  final factories = <Type, T Function(Map<String, dynamic>)>{
    User: (Map<String, dynamic> json) => User.fromJson(json) as T, 
    Message: (Map<String, dynamic> json) => Message.fromJson(json) as T,
  };

  final instance = factories[T];
  return instance?.call(json);
}

void cacheInstanceOf<T>(T instance) {
  final Isar isarDb = GetIt.instance<Isar>();

  final factories = <Type, void Function(dynamic)>{
    User: (dynamic localUser) async {
      final isarUser = DbUser()
        ..userId = localUser.id
        ..displayName = localUser.displayName
        ..photoUrl = localUser.photoUrl;
      await isarDb.writeTxn(() async => await isarDb.dbUsers.put(isarUser));
    },
    Message: (dynamic message) async {}
  };

  final action = factories[T];
  action?.call(instance);
}
