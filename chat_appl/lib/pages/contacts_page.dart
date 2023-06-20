import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/avatar_circle.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, required this.dbService});

  final DatabaseService dbService;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: StreamBuilder(
        builder: (context, snapshot) {
          if (
            snapshot.hasData
            && snapshot.data != null
            && snapshot.data!.isNotEmpty
          ) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (BuildContext context, int index) {
                final User user = snapshot.data![index];
                bool hasAvatar = false;
                if (user.photoUrl != '') {
                  hasAvatar = true;
                }
                return ListTile(
                  leading: ProfileAvatar(
                    hasAvatar: hasAvatar,
                    avatarUrl: user.photoUrl,
                  ),
                  title: Text(user.displayName),
                );
              }
            );
          } else {
            return const Text('No Contacts');
          }
        },
        stream: widget.dbService.contactsStream,
      )
    );
  }
}