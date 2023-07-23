import 'dart:async';

import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_links/uni_links.dart';
import 'package:get_it/get_it.dart';

import 'package:chat_appl/pages/chats_page.dart';
import 'package:chat_appl/pages/contacts_page.dart';
import 'package:chat_appl/pages/settings/settings_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _initUser() async {
    final currUser = FirebaseAuth.instance.currentUser;
    final DatabaseService dbService = GetIt.instance<DatabaseService>();
    final User? user = await dbService.getUser(currUser!.uid);
    if (user == null) {
      dbService.addOrUpdateUserInfo(
        User(
          id: FirebaseAuth.instance.currentUser!.uid,
          displayName: FirebaseAuth.instance.currentUser!.uid.substring(0, 8),
          photoUrl: ''
        ));
    }
  }

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _initUser();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Got DeepLink'))
        );
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        const ContactsPage(),
        const ChatsPage(),
        const SettingsPage(),
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