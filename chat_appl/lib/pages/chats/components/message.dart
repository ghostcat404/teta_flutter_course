import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageWidget extends StatefulWidget {
  final Message message;
  final User? user;

  const MessageWidget({super.key, required this.message, required this.user});

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
            mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == widget.user!.id
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
            children: [
              Text(
                widget.message.userDisplayName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(
                        StringToHex.toColor(widget.message.userDisplayName))),
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                timeago.format(DateTime.fromMillisecondsSinceEpoch(
                    widget.message.timestamp)),
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 13.0,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: FirebaseAuth.instance.currentUser!.uid == widget.user!.id
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
            children: [
              // TODO: style
              Text(
                widget.message.text,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          )
        ],
      ),
    );
  }
}
