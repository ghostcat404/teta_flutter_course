import 'dart:io';

import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/db_models/db_user_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'models/db_models/db_message.dart';
import 'models/db_models/db_user.dart';
import 'models/db_models/db_user_chat.dart';

class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "providerContainer:" "$container"
  "newValue": "$newValue"
  "previousValuse:" "$previousValue"
}''');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase init
  FirebaseApp firebaseApp = await Firebase.initializeApp(
    name: "chat_appl",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // dbInstance.setPersistenceEnabled(true);

  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  // NotificationSettings notificationSettings = await firebaseMessaging
  //     .requestPermission(alert: true, badge: true, sound: true);
  // if (notificationSettings.authorizationStatus ==
  //     AuthorizationStatus.authorized) {
  //   print('User granted permission');
  // } else {
  //   print('User declined or has not accepted permission');
  // }
  // final fcmToken = await firebaseMessaging.getToken();
  // print('fcmToken: $fcmToken');

  FirebaseUIAuth.configureProviders([
    PhoneAuthProvider(),
  ]);

  // Isar database init
  final Directory dir = await getApplicationDocumentsDirectory();
  final Isar isarDb = await Isar.open(
    [
      DbUserSchema,
      DbMessageSchema,
      DbUserChatSchema,
      DbUserSettingsSchema,
      DbUserProfileSchema
    ],
    directory: dir.path,
  );

  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<Isar>(isarDb);
  getIt.registerSingleton<FirebaseApp>(firebaseApp);
  runApp(ProviderScope(observers: [Logger()], child: const MyApp()));
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
