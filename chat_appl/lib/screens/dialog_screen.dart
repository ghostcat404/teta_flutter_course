import 'package:chat_appl/chat_components/message.dart';
import 'package:chat_appl/screens/typing_field.dart';
import 'package:flutter/material.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key, required this.messageList});

  final List<dynamic> messageList;

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('MessagesView'),
      appBar: AppBar(
        title: const Text('Chat with user'),
      ),
      body: ListView.builder(
        reverse: true,
        itemCount: widget.messageList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: MessageWidget(
              message: widget.messageList[index],
            )
          );
        },
      ),
      bottomNavigationBar: TypingField(controller: _controller),
    );
  }
}