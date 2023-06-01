import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:string_to_hex/string_to_hex.dart';

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
  late DatabaseService dbService;
  MyHomePage({super.key, required this.title, required this.uuId, required this.firebaseApp}) {
    dbService = DatabaseService(firebaseApp: firebaseApp);
  }

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  // final _dbRef = FirebaseDatabase.instance.ref('messages');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              child: ListView.builder(
                reverse: true,
                itemCount: (snapshot.data!).length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              (snapshot.data!)[index].userId.substring(0, 8),
                              // messageList[index].userId,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(StringToHex.toColor((snapshot.data!)[index].userId))
                              ),
                            ),
                            const SizedBox(width: 6,),
                            Text(
                              timeago.format(
                                DateTime.fromMillisecondsSinceEpoch((snapshot.data!)[index].timestamp)
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontSize: 13.0,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8
                        ),
                        Text(
                          (snapshot.data!)[index].text,
                          style: const TextStyle(fontSize: 16.0),
                        )
                      ]
                    ),
                  );
                },
              )
            );
          } else {
            return const Text('No Messages');
          }
        },
        stream: widget.dbService.messageStream,
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Row(
          children: [
            Expanded(
              child: BottomAppBar(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 16.0),
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)
                  )
                )
              ),
            ),
            IconButton(
              onPressed: () {
                widget.dbService.sendMessage(_controller.text, widget.uuId);
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
