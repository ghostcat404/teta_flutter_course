import 'dart:io';

import 'package:chat_appl/models/db_message.dart';
import 'package:chat_appl/models/db_user.dart';
import 'package:chat_appl/models/db_user_chat.dart';
import 'package:chat_appl/models/db_user_contact.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase init
  FirebaseApp firebaseApp = await Firebase.initializeApp(
    name: "chat_appl",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirebaseDatabase dbInstance =
      FirebaseDatabase.instanceFor(app: firebaseApp);
  // dbInstance.setPersistenceEnabled(true);

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  NotificationSettings notificationSettings = await firebaseMessaging
      .requestPermission(alert: true, badge: true, sound: true);
  if (notificationSettings.authorizationStatus ==
      AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }
  // final fcmToken = await firebaseMessaging.getToken();
  // print('fcmToken: $fcmToken');

  FirebaseUIAuth.configureProviders([
    PhoneAuthProvider(),
  ]);

  // Isar database init
  final Directory dir = await getApplicationDocumentsDirectory();
  final Isar isarDb = await Isar.open(
    [DbUserSchema, DbMessageSchema, DbUserContactSchema, DbUserChatSchema],
    directory: dir.path,
  );

  // Singleton instances init
  final GetIt getIt = GetIt.instance;

  final FirebaseDatabaseService dbService =
      FirebaseDatabaseService(dbInstance: dbInstance);
  final LocalDatabaseService localDbService =
      LocalDatabaseService(isarDbInstance: isarDb);
  final DatabaseRepository dbRepository = DatabaseRepository(
      localDbInstance: localDbService, dbInstance: dbService);
  getIt.registerSingleton<FirebaseDatabaseService>(dbService);
  getIt.registerSingleton<FirebaseMessaging>(firebaseMessaging);
  getIt.registerSingleton<NotificationSettings>(notificationSettings);
  getIt.registerSingleton<LocalDatabaseService>(localDbService);
  getIt.registerSingleton<DatabaseRepository>(dbRepository);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [PhoneAuthProvider()];
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 0, 4, 255),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home-page',
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
        '/home-page': (context) {
          return const HomePage();
        },
        '/phone': (context) => PhoneInputScreen(actions: [
              SMSCodeRequestedAction((context, action, flowKey, phoneNumber) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SMSCodeInputScreen(
                      actions: [
                        AuthStateChangeAction<SignedIn>((context, state) {
                          Navigator.of(context)
                              .pushReplacementNamed('/home-page');
                        })
                      ],
                      flowKey: flowKey,
                    ),
                  ),
                );
              }),
            ]),
      },
    );
  }
}
