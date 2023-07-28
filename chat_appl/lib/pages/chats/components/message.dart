import 'package:chat_appl/models/message.dart';
import 'package:flutter/material.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageWidget extends StatefulWidget {
  final Message message;

  const MessageWidget({super.key, required this.message});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.message.userId.substring(0, 8),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(StringToHex.toColor(widget.message.userId))
                ),
              ),
              const SizedBox(width: 6,),
              Text(
                timeago.format(
                  DateTime.fromMillisecondsSinceEpoch(widget.message.timestamp)
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
            widget.message.text,
            style: const TextStyle(fontSize: 16.0),
          )
        ],
      ),
    );
  }
}