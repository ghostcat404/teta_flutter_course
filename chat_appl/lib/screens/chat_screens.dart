import 'package:chat_appl/models/message.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:string_to_hex/string_to_hex.dart';
import 'package:flutter/material.dart';

class MessagesView extends StatefulWidget {
  final List<Message> messageList;

  const MessagesView({super.key, required this.messageList});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: widget.messageList.length,
      itemBuilder: (context, index) {
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
    );
  }
}