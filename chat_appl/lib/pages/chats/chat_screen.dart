import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/chats/components/message.dart';
import 'package:chat_appl/pages/chats/components/typing_field.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.messageList,
      required this.chatId,
      required this.user});

  final List<dynamic> messageList;
  final String chatId;
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
        title: const Text('Chat with user'),
      ),
      body: widget.messageList.isNotEmpty
          ? ListView.builder(
              reverse: true,
              itemCount: widget.messageList.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: MessageWidget(
                      message: widget.messageList[index],
                      user: widget.user,
                    ));
              },
            )
          : const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Center(child: Text('There are not messages yet'))],
              ),
            ),
      bottomNavigationBar: TypingField(
        controller: _controller,
        chatId: widget.chatId,
        userDisplayName: widget.user?.displayName,
      ),
    );
  }
}
