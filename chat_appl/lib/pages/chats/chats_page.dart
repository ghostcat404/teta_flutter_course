import 'dart:convert';
import 'dart:math';

import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/chat_settings.dart';
import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/chats/chat_screen.dart';
import 'package:chat_appl/services/firebase_database_service.dart';
import 'package:chat_appl/shimmers/chats_shimmers.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:searchfield/searchfield.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key, required this.user});

  final User? user;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late FirebaseDatabaseService dbService;

  final TextEditingController _searchFieldController = TextEditingController();

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<FirebaseDatabaseService>();
    super.initState();
  }

  void createChatWithUser(User? userB) async {
    final User? userA =
        await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
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
              lastMessage: '',
              lastMessageTimestamp: null));
      await dbService.addOrUpdateUserChatsInfo(
          userB.id,
          ChatInfo(
              chatId: chatId,
              userBId: userA.id,
              chatName: userA.displayName,
              lastMessage: '',
              lastMessageTimestamp: null));
      await dbService.createNewChat(chatId,
          ChatSettings(chatId: chatId, userAId: userA.id, userBId: userB.id));
    }
    final List<Message?> messageList =
        await GetIt.instance<FirebaseDatabaseService>()
            .getMessageListOnce(chatId);
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) =>
            ChatPage(messageList: messageList, chatId: chatId, user: userA)));
  }

  void selectUserToCreateAChat() {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) => StreamBuilder(
            stream: dbService.contactsStream,
            builder: (context, snapshot) {
              final bool dataIsLoaded =
                  snapshot.hasData && snapshot.data != null;
              return Scaffold(
                  appBar: AppBar(
                    title: const Text('Chats'),
                  ),
                  body: dataIsLoaded
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SearchField(
                                        onSuggestionTap: (SearchFieldListItem
                                                searchFieldItem) =>
                                            createChatWithUser(
                                                searchFieldItem.item),
                                        controller: _searchFieldController,
                                        suggestions: snapshot.data!
                                            .map((user) {
                                              if (FirebaseAuth.instance
                                                      .currentUser!.uid !=
                                                  user!.id) {
                                                return SearchFieldListItem<
                                                        User?>(user.displayName,
                                                    item: user,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Row(
                                                        children: [
                                                          ProfileAvatar(
                                                              hasAvatar:
                                                                  user.photoUrl ==
                                                                          ''
                                                                      ? false
                                                                      : true,
                                                              avatarUrl: user
                                                                  .photoUrl),
                                                          Text(user.displayName)
                                                        ],
                                                      ),
                                                    ));
                                              } else {
                                                return SearchFieldListItem('');
                                              }
                                            })
                                            .where((element) =>
                                                element.searchKey != '')
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () =>
                                          _searchFieldController.clear(),
                                      icon: const Icon(Icons.clear))
                                ],
                              ),
                            ],
                          ),
                        )
                      : const Text('Connection is unavailable'));
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
