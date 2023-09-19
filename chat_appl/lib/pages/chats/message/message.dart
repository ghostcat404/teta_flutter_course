import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';
import 'package:chat_appl/providers/state_providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_to_hex/string_to_hex.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageWidget extends ConsumerWidget {
  const MessageWidget({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettings? settings = ref.watch(userProfileNotifierProvider);
    return settings == null
        ? const CircularProgressIndicator()
        : Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: message.senderId == settings.userId
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      message.userDisplayName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(
                              StringToHex.toColor(message.userDisplayName))),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      timeago.format(DateTime.fromMillisecondsSinceEpoch(
                          message.timestamp)),
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
                  mainAxisAlignment: message.senderId == settings.userId
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(64.0),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableText(
                              message.text,
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
