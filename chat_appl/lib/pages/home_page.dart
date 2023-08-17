import 'dart:async';

import 'package:chat_appl/models/fb_models/user.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';
import 'package:get_it/get_it.dart';

import 'package:chat_appl/pages/chats/chats_page.dart';
import 'package:chat_appl/pages/contacts/contacts_page.dart';
import 'package:chat_appl/pages/profile/profile_page.dart';

const List<Widget> mainPageDestinations = <Widget>[
  NavigationDestination(
    icon: Icon(Icons.contacts),
    label: 'Contacts',
  ),
  NavigationDestination(
    icon: Icon(Icons.chat),
    label: 'Chats',
  ),
  NavigationDestination(
    icon: Icon(Icons.account_circle),
    label: 'Profile',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.currentPageIndex = 0,
  });

  final int currentPageIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  StreamSubscription? _onBackgroungMessageStream;
  StreamSubscription? _onMessageStream;
  StreamSubscription? _sub;
  User? _user;

  @override
  void dispose() {
    _sub?.cancel();
    _onBackgroungMessageStream?.cancel();
    _onMessageStream?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    currentPageIndex = widget.currentPageIndex;
    _initUser();
    _handleIncomingLinks();
    setupInteractedMessage();
    super.initState();
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    _onBackgroungMessageStream =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    _onMessageStream = FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    final Map<String, dynamic> messageData =
        Map<String, dynamic>.from(message.data);
    final UserChat? userChat = await GetIt.instance<FirebaseDatabaseService>()
        .getUserChatById(_user!.id, messageData['chatId']);
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) => ChatStream(
              userChat: userChat!,
              user: _user!,
              dbService: GetIt.instance<FirebaseDatabaseService>(),
            )));
  }

  Future<User> _initUser() async {
    // BUG: add user saving!!!
    // final SharedPreferences sh = await SharedPreferences.getInstance();
    final currFbUser = FirebaseAuth.instance.currentUser;
    final FirebaseDatabaseService dbService =
        GetIt.instance<FirebaseDatabaseService>();
    final currUser = await dbService.getUser(currFbUser!.uid);
    final User newUser = User(
      id: FirebaseAuth.instance.currentUser!.uid,
      displayName: FirebaseAuth.instance.currentUser!.uid.substring(0, 8),
      photoUrl: '',
    );
    if (currUser == null) {
      dbService.addOrUpdateUserInfo(newUser);
      // dbService.createOrUpdateUserContact(newUser.id, newUser.id);
    }
    _user = currUser ?? newUser;
    return _user!;
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        // print('got uri: $uri');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Got DeepLink')));
      }, onError: (Object err) {
        if (!mounted) return;
        // print('got err: $err');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // BUG: doesn't work wothout internet!!!
    // need to initialize user without internet connection!!!
    return _user == null
        ? FutureBuilder(
            future: _initUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.done &&
                  userSnapshot.hasData) {
                return MainPage(
                  user: _user!,
                  currentPageIndex: currentPageIndex,
                );
              }
              return Scaffold(
                  body: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  bottomNavigationBar:
                      NavigationBar(destinations: mainPageDestinations));
            })
        : MainPage(
            user: _user!,
            currentPageIndex: currentPageIndex,
          );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.user,
    this.currentPageIndex = 0,
  });

  final int currentPageIndex;
  final User user;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;

  @override
  void initState() {
    currentPageIndex = widget.currentPageIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        ContactsPage(
          user: widget.user,
          dbService: GetIt.instance<FirebaseDatabaseService>(),
          dbRepository: GetIt.instance<DatabaseRepository>(),
        ),
        ChatsPage(
          user: widget.user,
          dbService: GetIt.instance<FirebaseDatabaseService>(),
          dbRepository: GetIt.instance<DatabaseRepository>(),
        ),
        const ProfilePage(),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: mainPageDestinations),
    );
  }
}
