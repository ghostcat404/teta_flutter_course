import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  final FirebaseApp firebaseApp;
  late FirebaseDatabase dbInstance;

  DatabaseService({required this.firebaseApp}) {
    dbInstance = FirebaseDatabase.instanceFor(app: firebaseApp);
  }

  Future updateUserInfo({String? displayName, String? photoUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    final DatabaseReference dbRef = dbInstance.ref().child('users/${prefs.getString("uuid")}');
    final user = User(
      id: prefs.getString('uuid')!, 
      displayName: displayName ?? prefs.getString('displayName')!,
      photoUrl: photoUrl ?? prefs.getString('photoUrl')!
    );
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      await dbRef.update(user.toJson());
    } else {
      final userRef = dbRef.push();
      await userRef.set(user.toJson());
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

  Stream<List<T?>> _getStreamByRef<T>(String refName) {
    return dbInstance.ref(refName).onValue.map((event) {
      List<T?> dataList = [];
      if (event.snapshot.value != null) {
        final firebaseMessages = Map<dynamic, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
        firebaseMessages.forEach((key, value) {
          final currentData = Map<String, dynamic>.from(value);
          final T? instance = createInstanceOf<T>(currentData);
          dataList.add(instance);
        });
      }
      return dataList;
    });
  }

  Stream<List<dynamic>> get messageStream => _getStreamByRef<Message>('messages');
  Stream<List<dynamic>> get contactsStream => _getStreamByRef<User>('users');
}

T? createInstanceOf<T>(Map<String, dynamic> json) {
  final factories = <Type, T Function(Map<String, dynamic>)>{
    User: (Map<String, dynamic> json) => User.fromJson(json) as T, 
    Message: (Map<String, dynamic> json) => Message.fromJson(json) as T,
  };

  final instance = factories[T];
  return instance?.call(json);
}
