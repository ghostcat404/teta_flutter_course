import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';
import 'package:chat_appl/pages/chats/chats_page.dart';
import 'package:chat_appl/pages/contacts/contacts_page.dart';
import 'package:chat_appl/pages/profile/profile_page.dart';
import 'package:chat_appl/providers/state_providers/home_page_provider.dart';
import 'package:chat_appl/providers/state_providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class HomePage extends ConsumerWidget {
  const HomePage({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettings? settings = ref.watch(userProfileNotifierProvider);
    final int currentPageIndex = ref.watch(homePageStateProvider(initialIndex));
    return settings == null
        ? const DefaultProgressIndicator()
        : Scaffold(
            body: <Widget>[
              const ContactsPage(),
              const ChatsPage(),
              const ProfilePage(),
            ][currentPageIndex],
            bottomNavigationBar: NavigationBar(
                onDestinationSelected: (int index) => ref
                    .read(homePageStateProvider(initialIndex).notifier)
                    .moveToAnotherPage(index),
                selectedIndex: currentPageIndex,
                destinations: mainPageDestinations),
          );
  }
}
