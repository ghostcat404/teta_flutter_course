import 'dart:math';

import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/chat_settings.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/chats/dialog_screen.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:chat_appl/shimmers/chats_shimmers.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late DatabaseService dbService;

  @override
  void initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<DatabaseService>();
    super.initState();
  }

  void createChatWithUser() async {
    final User? userA =
        await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    const String userBId = 'sFv4LRlpipaiTBchN3d5vGv5cNu1';
    final User? userB = await dbService.getUser(userBId);
    final String chatId =
        md5.convert(utf8.encode(userA!.id + userB!.id)).toString();
    final ChatInfo? userAChatInfo =
        await dbService.getUserChatsInfo(userA.id, chatId);
    if (userAChatInfo == null) {
      await dbService.addOrUpdateUserChatsInfo(
          userA.id,
          ChatInfo(
              chatId: chatId,
              userBId: userB.id,
              chatName: userB.displayName,
              lastMessage: 'lastMsg'));
      await dbService.addOrUpdateUserChatsInfo(
          userB.id,
          ChatInfo(
              chatId: chatId,
              userBId: userA.id,
              chatName: userB.displayName,
              lastMessage: 'lastMsg'));
      await dbService.createNewChat(chatId,
          ChatSettings(chatId: chatId, userAId: userA.id, userBId: userB.id));
    }
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
              onPressed: createChatWithUser,
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
                    subtitle: Text(
                        '${chatInfo.lastMessage.substring(0, min(chatInfo.lastMessage.length, 16))}...'),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, _, __) => StreamBuilder(
                            builder: (context, messageSnapshot) {
                              // TODO: Fix!
                              bool dataIsLoaded = (messageSnapshot.hasData &&
                                  messageSnapshot.data != null &&
                                  messageSnapshot.data!.isNotEmpty);
                              return AnimatedSwitcher(
                                duration: const Duration(seconds: 1),
                                child: dataIsLoaded
                                    ? MessagesView(
                                        messageList: messageSnapshot.data!,
                                        chatId: chatInfo.chatId,
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
              return const Text('There is no chats yet');
            }
          },
          stream: dbService
              .getChatInfoStream(FirebaseAuth.instance.currentUser!.uid),
        ));
  }
}
