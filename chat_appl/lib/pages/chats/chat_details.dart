import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/models/user_chat.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:flutter/material.dart';

class ChatDetailsScreen extends StatelessWidget {
  const ChatDetailsScreen(
      {super.key,
      required this.dbService,
      required this.userChat,
      required this.currUser});

  final UserChat userChat;
  final User currUser;
  final FirebaseDatabaseService dbService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat Details'),
        ),
        body: BaseSizedBoxColumn(children: [
          NamePhotoCard(
            name: userChat.chatName,
            photoUrl: userChat.chatPhotoUrl,
          ),
          FloatingActionButton.large(
              onPressed: () async {
                await deleteChat(currUser.id, userChat, dbService);
                Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                        pageBuilder: (context, _, __) => const HomePage(
                              currentPageIndex: 1,
                            )),
                    (r) => false);
              },
              child: const Icon(Icons.delete_forever))
        ]));
  }
}
