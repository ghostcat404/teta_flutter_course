import 'package:chat_appl/pages/chats_page.dart';
import 'package:chat_appl/pages/contacts_page.dart';
import 'package:chat_appl/pages/settings_page.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
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
    await prefs.setString('uuid', uuId);
  }
  runApp(MyApp(uuId: uuId, firebaseApp: firebaseApp,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.uuId, required this.firebaseApp});

  final FirebaseApp firebaseApp;
  final String uuId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: MyHomePage(title: 'Chat', uuId: uuId, firebaseApp: firebaseApp,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.uuId, required this.firebaseApp});

  final FirebaseApp firebaseApp;
  final String title;
  final String uuId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  late DatabaseService dbService;

  final TextEditingController _controller = TextEditingController();

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
      body: <Widget>[
        ContactsPage(dbService: dbService,),
        ChatsPage(dbService: dbService,),
        SettingsPage(dbService: dbService,),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
