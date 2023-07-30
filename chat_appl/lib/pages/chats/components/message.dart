import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
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
  // TODO: fix diff users
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.message.userDisplayName == widget.user!.displayName
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
          // TODO: fix long messages
          Row(
            mainAxisAlignment: widget.message.userDisplayName == widget.user!.displayName
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.message.text,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
