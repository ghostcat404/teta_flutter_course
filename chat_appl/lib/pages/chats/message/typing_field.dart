import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';
import 'package:chat_appl/providers/default_providers.dart';
import 'package:chat_appl/providers/state_providers/chat_page_provider.dart';
import 'package:chat_appl/providers/state_providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypingField extends ConsumerWidget {
  const TypingField({super.key, required this.chatId, required this.contactId});
  final String chatId;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettings? settings = ref.watch(userProfileNotifierProvider);
    final TextEditingController controller =
        ref.watch(textControllerProvider());
    return settings == null
        ? const DefaultProgressIndicator()
        : Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: BottomAppBar(
                child: Row(
              children: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.add_box_outlined)),
                Expanded(
                  child: TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 16.0),
                      decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0))),
                ),
                IconButton(
                  onPressed: () async {
                    await ref
                        .read(chatPageStateProvider(chatId: chatId).notifier)
                        .sendMessage(controller.text, chatId, contactId);
                    controller.clear();
                  },
                  icon: const Icon(Icons.send),
                  color: Colors.blue[900],
                )
              ],
            )),
          );
  }
}
