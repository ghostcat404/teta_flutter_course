import 'package:chat_appl/models/message.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {

  Future sendMessage(String text, String uuid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('messages');
    final message = Message(
      userId: uuid,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString()
    );
    final messageRef = ref.push();
    await messageRef.set(message.toJson());
  }
}
