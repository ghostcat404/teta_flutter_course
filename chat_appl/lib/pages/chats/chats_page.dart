import 'dart:math';

import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
    // TODO: fix
    final User? userA =
        await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    const String userBId = 'sFv4LRlpipaiTBchN3d5vGv5cNu1';
    final User? userB = await dbService.getUser(userBId);
    final ChatInfo? userAChatInfo =
        await dbService.getUserChatsInfo(userA!.id, userB!.id);
    if (userAChatInfo == null) {
      await dbService.addOrUpdateUserChatsInfo(
          userA.id,
          ChatInfo(
              chatId: userB.id, userBId: userB.id, lastMessage: 'lastMsg'));
      await dbService.addOrUpdateUserChatsInfo(
          userB.id,
          ChatInfo(
              chatId: userA.id, userBId: userA.id, lastMessage: 'lastMsg'));
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
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final ChatInfo? chatInfo = snapshot.data![index];
                  // final User userB = dbService.getUser(chatInfo!.userBId);
                  return ListTile(
                    title: Text(chatInfo!.userBId.substring(0, 8)),
                    subtitle: Text(
                        '${chatInfo.lastMessage.substring(0, min(chatInfo.lastMessage.length, 16))}...'),
                    onTap: () {
                      // TODO: fix
                      // Navigator.of(context).push(
                      //   PageRouteBuilder(
                      //     pageBuilder: (context, _, __) => StreamBuilder(
                      //       builder: (context, snapshot) {
                      //         bool dataIsLoaded = (snapshot.hasData &&
                      //             snapshot.data != null &&
                      //             snapshot.data!.isNotEmpty);
                      //         return AnimatedSwitcher(
                      //           duration: const Duration(seconds: 1),
                      //           child: dataIsLoaded
                      //               ? MessagesView(messageList: snapshot.data!)
                      //               : const ListMessagesShimmer(),
                      //         );
                      //       },
                      //       stream: dbService.messageStream,
                      //     ),
                      //     transitionsBuilder: (context, animation, _, child) {
                      //       const begin = Offset(0.0, 1.0);
                      //       const end = Offset.zero;
                      //       const curve = Curves.ease;

                      //       var tween = Tween(begin: begin, end: end)
                      //           .chain(CurveTween(curve: curve));

                      //       return SlideTransition(
                      //         position: animation.drive(tween),
                      //         child: child,
                      //       );
                      //     },
                      //   ),
                      // );
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
        )
        // body: ListView(
        //   children: <Widget>[
        //     ListTile(
        //       leading: const CircleAvatar(child: Text('A')),
        //       title: const Text('John Doe'),
        //       subtitle: const Text('Hello!'),
        //       trailing: const Text('31.05.2023'),
        //       onTap: () {
        //       },
        //     ),
        //     const Divider(height: 0),
        //   ],
        // ),
        );
  }
}
