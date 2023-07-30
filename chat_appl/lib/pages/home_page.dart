import 'dart:async';

import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/chats/chat_screen.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';
import 'package:get_it/get_it.dart';

import 'package:chat_appl/pages/chats/chats_page.dart';
import 'package:chat_appl/pages/contacts/contacts_page.dart';
import 'package:chat_appl/pages/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  StreamSubscription? _sub;
  StreamSubscription? _onMessageStream;
  StreamSubscription? _onBackgroungMessageStream;
  User? _user;

  @override
  void initState() {
    _initUser();
    _handleIncomingLinks();
    setupInteractedMessage();
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _onBackgroungMessageStream?.cancel();
    _onMessageStream?.cancel();
    super.dispose();
  }

  void _handleMessage(RemoteMessage message) async {
    final Map<String, dynamic> messageData =
        Map<String, dynamic>.from(message.data);
    final List<Message?> messageList = await GetIt.instance<DatabaseService>()
        .getMessageListOnce(messageData['chatId']);
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) => ChatPage(
            messageList: messageList,
            chatId: messageData['chatId'],
            user: _user!)));
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

  Future _initUser() async {
    final currFbUser = FirebaseAuth.instance.currentUser;
    final DatabaseService dbService = GetIt.instance<DatabaseService>();
    final currUser = await dbService.getUser(currFbUser!.uid);
    final User newUser = User(
      id: FirebaseAuth.instance.currentUser!.uid,
      displayName: FirebaseAuth.instance.currentUser!.uid.substring(0, 8),
      photoUrl: '',
    );
    if (currUser == null) dbService.addOrUpdateUserInfo(newUser);
    _user = currUser ?? newUser;
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
    return Scaffold(
      body: <Widget>[
        ContactsPage(user: _user),
        ChatsPage(
          user: _user,
        ),
        SettingsPage(user: _user),
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
