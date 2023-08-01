import 'dart:math';

import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/chats/chat_creation_page.dart';
import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/services/firebase_database_service.dart';
import 'package:chat_appl/shimmers/chats_shimmers.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key, required this.user});

  final User? user;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late FirebaseDatabaseService dbService;

  @override
  void initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<FirebaseDatabaseService>();
    super.initState();
  }

  void selectUserToCreateAChat() {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) => StreamBuilder(
            stream: dbService.contactsStream,
            builder: (context, snapshot) {
              final bool dataIsLoaded =
                  snapshot.hasData && snapshot.data != null;
              return ChatCreationPage(
                dataIsLoaded: dataIsLoaded,
                dbService: dbService,
                snapshot: snapshot,
              );
            })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              iconSize: 25.0,
              onPressed: selectUserToCreateAChat,
            )
          ],
        ),
        body: StreamBuilder(
          builder: (context, chatInfoSnapshot) {
            if (chatInfoSnapshot.hasData &&
                chatInfoSnapshot.data != null &&
                chatInfoSnapshot.data!.isNotEmpty) {
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: chatInfoSnapshot.data!.length,
                itemBuilder: (context, index) {
                  final ChatInfo? chatInfo = chatInfoSnapshot.data![index];
                  return ListTile(
                    title: Text(chatInfo!.chatName),
                    trailing: Text(chatInfo.lastMessageTimestamp == null
                        ? ''
                        : timeago
                            .format(DateTime.fromMillisecondsSinceEpoch(
                                chatInfo.lastMessageTimestamp!))
                            .toString()),
                    subtitle: Text(chatInfo.lastMessage == ''
                        ? ''
                        : '${chatInfo.lastMessage.substring(0, min(chatInfo.lastMessage.length, 16))}...'),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, _, __) => StreamBuilder(
                            builder: (context, messageSnapshot) {
                              bool dataIsLoaded = (messageSnapshot.hasData &&
                                  messageSnapshot.data != null);
                              return AnimatedSwitcher(
                                duration: const Duration(seconds: 1),
                                child: dataIsLoaded
                                    ? ChatPage(
                                        messageList: messageSnapshot.data!,
                                        chatId: chatInfo.chatId,
                                        user: widget.user,
                                      )
                                    : const ListMessagesShimmer(),
                              );
                            },
                            stream: dbService.getMessageStream(chatInfo.chatId),
                          ),
                          transitionsBuilder: (context, animation, _, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('There is no chats yet'),
                    ],
                  ),
                ],
              );
            }
          },
          stream: dbService
              .getChatInfoStream(FirebaseAuth.instance.currentUser!.uid),
        ));
  }
}
