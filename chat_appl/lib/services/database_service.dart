import 'package:chat_appl/models/message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseApp firebaseApp;
  late DatabaseReference dbRef;

  DatabaseService({required this.firebaseApp}) {
    dbRef = FirebaseDatabase.instanceFor(app: firebaseApp).ref('messages');
  }

  Future sendMessage(String text, String uuid) async {
    final message = Message(
      userId: uuid,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch
    );
    final messageRef = dbRef.push();
    await messageRef.set(message.toJson());
  }
}
