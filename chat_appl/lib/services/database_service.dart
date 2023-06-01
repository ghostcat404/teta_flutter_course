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

  Stream<List<Message>> get messageStream => dbRef.onValue.map((event) {
    List<Message> messageList = [];
    if (event.snapshot.value != null) {
      final firebaseMessages = Map<dynamic, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
      firebaseMessages.forEach((key, value) {
        final currentMessage = Map<String, dynamic>.from(value);
        messageList.add(Message.fromMap(currentMessage));
      });
    }
    return messageList;
  });
}
