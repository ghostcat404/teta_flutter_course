import 'dart:convert';

import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/chat_settings.dart';
import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/services/firebase_database_service.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:searchfield/searchfield.dart';

class ChatCreationPage extends StatefulWidget {
  const ChatCreationPage(
      {super.key,
      required this.dataIsLoaded,
      required this.dbService,
      required this.snapshot});

  final bool dataIsLoaded;
  final FirebaseDatabaseService dbService;
  final AsyncSnapshot<List<User?>> snapshot;

  @override
  State<ChatCreationPage> createState() => _ChatCreationPageState();
}

class _ChatCreationPageState extends State<ChatCreationPage> {
  final TextEditingController _searchFieldController = TextEditingController();

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  void createChatWithUser(User? userB) async {
    final User? userA =
        await widget.dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    final String chatId =
        md5.convert(utf8.encode(userA!.id + userB!.id)).toString();
    final ChatInfo? userAChatInfo =
        await widget.dbService.getUserChatsInfo(userA.id, chatId);
    if (userAChatInfo == null) {
      await widget.dbService.addOrUpdateUserChatsInfo(
          userA.id,
          ChatInfo(
              chatId: chatId,
              userBId: userB.id,
              chatName: userB.displayName,
              lastMessage: '',
              lastMessageTimestamp: null));
      await widget.dbService.addOrUpdateUserChatsInfo(
          userB.id,
          ChatInfo(
              chatId: chatId,
              userBId: userA.id,
              chatName: userA.displayName,
              lastMessage: '',
              lastMessageTimestamp: null));
      await widget.dbService.createNewChat(chatId,
          ChatSettings(chatId: chatId, userAId: userA.id, userBId: userB.id));
    }
    final List<Message?> messageList =
        await GetIt.instance<FirebaseDatabaseService>()
            .getMessageListOnce(chatId);
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) =>
            ChatPage(messageList: messageList, chatId: chatId, user: userA)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: widget.dataIsLoaded
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
                              onSuggestionTap:
                                  (SearchFieldListItem searchFieldItem) =>
                                      createChatWithUser(searchFieldItem.item),
                              controller: _searchFieldController,
                              suggestions: widget.snapshot.data!
                                  .map((user) {
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        user!.id) {
                                      return SearchFieldListItem<User?>(
                                          user.displayName,
                                          item: user,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              children: [
                                                ProfileAvatar(
                                                    hasAvatar:
                                                        user.photoUrl == ''
                                                            ? false
                                                            : true,
                                                    avatarUrl: user.photoUrl),
                                                Text(user.displayName)
                                              ],
                                            ),
                                          ));
                                    } else {
                                      return SearchFieldListItem('');
                                    }
                                  })
                                  .where((element) => element.searchKey != '')
                                  .toList(),
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () => _searchFieldController.clear(),
                            icon: const Icon(Icons.clear))
                      ],
                    ),
                  ],
                ),
              )
            : const Text('Connection is unavailable'));
  }
}
