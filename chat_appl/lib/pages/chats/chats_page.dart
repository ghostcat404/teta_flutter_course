// TODO: refactoring
import 'dart:async';
import 'dart:math';

import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/models/user_chat.dart';
import 'package:chat_appl/components/user_selection_page.dart';
import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:chat_appl/utils/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatUIWidget extends StatelessWidget {
  const ChatUIWidget({super.key, required this.userChat});

  final UserChat userChat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // TODO: add contact image
      title: Text(userChat.chatName),
      trailing: Text(userChat.lastMessageTimestamp == null
          ? ''
          : timeago
              .format(DateTime.fromMillisecondsSinceEpoch(
                  userChat.lastMessageTimestamp!))
              .toString()),
      subtitle: Text(userChat.lastMessage == ''
          ? ''
          : '${userChat.lastMessage.substring(0, min(userChat.lastMessage.length, 16))}...'),
    );
  }
}

class ChatsPage extends StatefulWidget {
  const ChatsPage(
      {super.key,
      required this.user,
      required this.dbRepository,
      required this.dbService});

  final User? user;
  final DatabaseRepository dbRepository;
  final FirebaseDatabaseService dbService;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
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

  void selectUserToCreateAChat() {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) => StreamBuilder(
            stream: widget.dbService.getUsersStream,
            builder: (context, snapshot) {
              final bool dataIsLoaded =
                  snapshot.hasData && snapshot.data != null;
              return SelectionPage(
                appBarTitle: 'Create Chat',
                dataIsLoaded: dataIsLoaded,
                dbService: widget.dbService,
                snapshot: snapshot,
                function: createChatWithUser,
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
              onPressed: selectUserToCreateAChat,
            ),
          ],
        ),
        body: FutureBuilder(
            future: checkConnection(),
            builder: (context, connectionSnapshot) {
              if (connectionSnapshot.connectionState == ConnectionState.done &&
                  connectionSnapshot.hasData) {
                return StreamBuilder(
                    stream: widget.dbRepository.getUserChatsStream(
                        widget.user!.id, connectionSnapshot.data!),
                    builder: (context, userChatsSnapshot) {
                      if (userChatsSnapshot.hasData &&
                          userChatsSnapshot.data != null &&
                          userChatsSnapshot.data!.isNotEmpty) {
                        final List<UserChat?> userChats =
                            userChatsSnapshot.data!;
                        return ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount: userChats.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, _, __) =>
                                          ChatStream(
                                        userChat: userChats[index]!,
                                        user: widget.user!,
                                        dbService: widget.dbService,
                                      ),
                                      transitionsBuilder:
                                          (context, animation, _, child) {
                                        const begin = Offset(0.0, 1.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: ChatUIWidget(
                                  userChat: userChats[index]!,
                                ));
                          },
                        );
                      }
                      return const NoDataWidget('There is no chats yet');
                    });
              }
              return const DefaultProgressIndicator();
            }));
  }
}
