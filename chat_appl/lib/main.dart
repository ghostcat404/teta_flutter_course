import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp(
    name: "chat_appl",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([
    PhoneAuthProvider(),
  ]);

  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<DatabaseService>(DatabaseService(firebaseApp: firebaseApp));
  
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uuId = prefs.getString('uuid');
  if (uuId == null) {
    uuId = const Uuid().v4();
    await prefs.setString('uuid', uuId);
    final DatabaseService dbService = getIt<DatabaseService>();
    dbService.addOrUpdateUserInfo(displayName: uuId, photoUrl: '');
  }
  runApp(MyApp(uuId: uuId, firebaseApp: firebaseApp,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.uuId, required this.firebaseApp});

  final FirebaseApp firebaseApp;
  final String uuId;

  @override
  Widget build(BuildContext context) {
    final providers = [PhoneAuthProvider()];
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: const HomePage(),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              VerifyPhoneAction((context, action) {
                Navigator.pushNamed(context, '/phone');
              })
            ],
          );
        },
        '/profile': (context) {
          return const HomePage();
        },
        '/phone': (context) => PhoneInputScreen(
          actions: [
            SMSCodeRequestedAction((context, action, flowKey, phoneNumber) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SMSCodeInputScreen(
                    flowKey: flowKey,
                  ),
                ),
              );
            }),
          ]
        ),
      },
    );
  }
}