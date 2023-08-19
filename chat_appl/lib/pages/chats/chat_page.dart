import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/pages/chats/chat_details.dart';
import 'package:chat_appl/pages/chats/message/message.dart';
import 'package:chat_appl/pages/chats/message/typing_field.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/providers/stream_providers/stream_providers.dart';
import 'package:chat_appl/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesList extends ConsumerWidget {
  const MessagesList({super.key, required this.messages});
  final List<Message?> messages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        return MessageWidget(
          message: messages[index]!,
        );
      },
    );
  }
}

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key, required this.chat, required this.contactId});
  final UserChat chat;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesStream =
        ref.watch(messagesStreamProvider(chatId: chat.chatId));
    return messagesStream.when(
        data: (messages) {
          return Scaffold(
            key: const ValueKey('ChatPage'),
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    pushPageAndRemoveAll(
                        context, const HomePage(initialIndex: 1));
                  }),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(chat.chatName),
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () => pushPage(
                        context,
                        ChatDetailsScreen(
                          userChat: chat,
                        )),
                    icon: const Icon(Icons.settings))
              ],
            ),
            body: messages.isNotEmpty
                ? MessagesList(messages: messages)
                : const NoDataWidget('There are not messages yet'),
            bottomNavigationBar: TypingField(
              chatId: chat.chatId,
              contactId: contactId,
            ),
          );
        },
        error: (error, stackTrace) => ErrorHandledWidget(error: error),
        loading: () => const DefaultProgressIndicator());
  }
}
