import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_contact.dart';
import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactButtonWidget extends StatelessWidget {
  const ContactButtonWidget(
      {super.key,
      required this.icon,
      required this.buttonName,
      this.onTapFunction});

  final Function()? onTapFunction;
  final String buttonName;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      heroTag: buttonName,
      onPressed: onTapFunction,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon, Text(buttonName)],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});

  final UserContact contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Info')),
      body: BaseSizedBoxColumn(
        children: [
          NamePhotoCard(photoUrl: contact.photoUrl, name: contact.displayName),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContactButtonWidget(
                  icon: const Icon(Icons.message),
                  buttonName: 'Message',
                  onTapFunction: () async {
                    ChatStream chatStream = await getOrCreateChatWithUser(
                        contact, GetIt.instance<FirebaseDatabaseService>());
                    Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, _, __) => chatStream));
                  },
                ),
                ContactButtonWidget(
                  icon: const Icon(Icons.delete_forever),
                  buttonName: 'Delete User',
                  onTapFunction: () {
                    deleteContact(
                        contact, GetIt.instance<FirebaseDatabaseService>());
                    Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, _, __) => const HomePage()));
                  },
                ),
                ContactButtonWidget(
                  icon: const Icon(Icons.more_horiz),
                  buttonName: 'More',
                  onTapFunction: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Hey! You are the best!')));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
