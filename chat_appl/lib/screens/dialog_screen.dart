// import 'package:chat_appl/screens/typing_field.dart';
import 'package:chat_appl/screens/typing_field.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:string_to_hex/string_to_hex.dart';
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
      appBar: AppBar(
        title: const Text('Chat with user'),
      ),
      body: ListView.builder(
        reverse: true,
        itemCount: widget.messageList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.messageList[index].userId.substring(0, 8),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(StringToHex.toColor(widget.messageList[index].userId))
                      ),
                    ),
                    const SizedBox(width: 6,),
                    Text(
                      timeago.format(
                        DateTime.fromMillisecondsSinceEpoch(widget.messageList[index].timestamp)
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8
                ),
                Text(
                  widget.messageList[index].text,
                  style: const TextStyle(fontSize: 16.0),
                )
              ]
            ),
          );
        },
      ),
      bottomNavigationBar: TypingField(controller: _controller),
    );
  }
}