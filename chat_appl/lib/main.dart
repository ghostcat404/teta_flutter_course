import 'package:chat_appl/screens/dialog_screen.dart';
import 'package:chat_appl/screens/typing_field.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp(
    name: "chat_appl",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uuId = prefs.getString('uuid');
  if (uuId == null) {
    uuId = const Uuid().v4();
    prefs.setString('uuid', uuId);
  }
  runApp(MyApp(uuId: uuId, firebaseApp: firebaseApp,));
}

class MyApp extends StatelessWidget {
  final String uuId;
  final FirebaseApp firebaseApp;
  const MyApp({super.key, required this.uuId, required this.firebaseApp});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Chat', uuId: uuId, firebaseApp: firebaseApp,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String uuId;
  final FirebaseApp firebaseApp;
  const MyHomePage({super.key, required this.title, required this.uuId, required this.firebaseApp});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  late DatabaseService dbService;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    dbService = DatabaseService(firebaseApp: widget.firebaseApp);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        builder: (context, snapshot) {
          if (
            snapshot.hasData
            && snapshot.data != null
            && (snapshot.data!).isNotEmpty
          ) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: MessagesView(messageList: (snapshot.data!)),
            );
          } else {
            return const Text('No Messages');
          }
        },
        stream: dbService.messageStream,
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Row(
          children: [
            TypingField(controller: _controller),
            IconButton(
              onPressed: () {
                dbService.sendMessage(_controller.text, widget.uuId);
                _controller.text = '';
              },
              icon: const Icon(Icons.send)
            )
          ],
        ),
      ),
    );
  }
}
