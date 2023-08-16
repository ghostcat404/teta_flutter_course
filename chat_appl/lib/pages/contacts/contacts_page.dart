import 'dart:async';

import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/models/user_contact.dart';
import 'package:chat_appl/components/user_selection_page.dart';
import 'package:chat_appl/pages/contacts/contact_widgets.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:chat_appl/utils/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage(
      {super.key,
      required this.user,
      required this.dbRepository,
      required this.dbService});

  final User? user;
  final DatabaseRepository dbRepository;
  final FirebaseDatabaseService dbService;
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  StreamSubscription? _connectivitySubscription;

  void handleConnectionIsAvailable(ConnectivityResult connectivityResult) {
    setState(() {});
  }

  @override
  void initState() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(handleConnectionIsAvailable);
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void selectUserToCreateAContact() {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) => StreamBuilder(
            stream: widget.dbService.getUsersStream,
            builder: (context, snapshot) {
              final bool dataIsLoaded =
                  snapshot.hasData && snapshot.data != null;
              return SelectionPage(
                appBarTitle: 'Create Contact',
                dataIsLoaded: dataIsLoaded,
                dbService: widget.dbService,
                snapshot: snapshot,
                function: createContactWithUser,
              );
            })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              iconSize: 25.0,
              onPressed: selectUserToCreateAContact,
            )
          ],
        ),
        body: FutureBuilder(
            future: checkConnection(),
            builder: (context, connectionSnapshot) {
              if (connectionSnapshot.connectionState == ConnectionState.done &&
                  connectionSnapshot.hasData) {
                return StreamBuilder(
                  stream: widget.dbRepository.getContactsStream(
                      widget.user!.id, connectionSnapshot.data!),
                  builder: (context, userContactsSnapshot) {
                    if (userContactsSnapshot.hasData &&
                        userContactsSnapshot.data != null &&
                        userContactsSnapshot.data!.isNotEmpty) {
                      final List<UserContact?> userContacts =
                          userContactsSnapshot.data!;
                      return ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount: userContacts.length,
                          itemBuilder: (context, index) {
                            final UserContact? contactUser =
                                userContacts[index];
                            return ListTile(
                              leading: ProfileAvatar(
                                avatarUrl: contactUser!.photoUrl,
                              ),
                              title: Text(contactUser.displayName),
                              onTap: () => Navigator.of(context).push(
                                  PageRouteBuilder(
                                      pageBuilder: (context, _, __) =>
                                          ContactCard(contact: contactUser))),
                            );
                          });
                    }
                    return const NoDataWidget('There are no contacts yet');
                  },
                );
              }
              return const DefaultProgressIndicator();
            }));
  }
}
