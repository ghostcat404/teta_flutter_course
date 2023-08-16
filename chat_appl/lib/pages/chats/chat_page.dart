import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/models/user_chat.dart';
import 'package:chat_appl/pages/chats/chat_details.dart';
import 'package:chat_appl/pages/chats/components/message.dart';
import 'package:chat_appl/pages/chats/components/typing_field.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:chat_appl/shimmers/chats_shimmers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatStream extends StatelessWidget {
  const ChatStream(
      {super.key,
      required this.userChat,
      required this.user,
      required this.dbService});

  final UserChat userChat;
  final FirebaseDatabaseService dbService;
  final User user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, messageSnapshot) {
        bool dataIsLoaded =
            (messageSnapshot.hasData && messageSnapshot.data != null);
        return AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: dataIsLoaded
              ? ChatPage(
                  messageList: messageSnapshot.data!,
                  userChat: userChat,
                  user: user,
                  dbService: dbService,
                  contactId: userChat.contactId,
                )
              : const ListMessagesShimmer(),
        );
      },
      stream: dbService.getMessageStream(userChat.chatId),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.contactId,
      required this.messageList,
      required this.userChat,
      required this.user,
      required this.dbService});

  final UserChat userChat;
  final String contactId;
  final FirebaseDatabaseService dbService;
  final List<dynamic> messageList;
  final User? user;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('ChatPage'),
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.previousRoute == ''
                // TODO: fix 3 tap to go to homepage
                ? Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                        pageBuilder: (context, _, __) => const HomePage(
                              currentPageIndex: 1,
                            )),
                    (r) => false)
                : Navigator.of(context).pop()),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: add chat image
            Text(widget.userChat.chatName),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, _, __) => ChatDetailsScreen(
                          currUser: widget.user!,
                          dbService: widget.dbService,
                          userChat: widget.userChat,
                        )));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: widget.messageList.isNotEmpty
          ? ListView.builder(
              reverse: true,
              itemCount: widget.messageList.length,
              itemBuilder: (BuildContext context, int index) {
                return MessageWidget(
                  message: widget.messageList[index],
                  user: widget.user,
                );
              },
            )
          : const NoDataWidget('There are not messages yet'),
      bottomNavigationBar: TypingField(
        controller: _controller,
        chatId: widget.userChat.chatId,
        userDisplayName: widget.user?.displayName,
        user: widget.user,
        contactId: widget.contactId,
      ),
    );
  }
}
