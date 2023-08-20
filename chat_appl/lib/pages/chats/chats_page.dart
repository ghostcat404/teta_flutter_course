// TODO: refactoring
import 'dart:math';

import 'package:chat_appl/components/buttons/default_buttons.dart';
import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:chat_appl/providers/stream_providers/stream_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:chat_appl/components/avatar_circle.dart';

class ChatUIWidget extends StatelessWidget {
  const ChatUIWidget({super.key, required this.userChat});

  final UserChat userChat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chat: userChat,
              contactId: userChat.contactId,
            ),
          ),
        );
      },
      title: Text(userChat.chatName),
      leading: ProfileAvatar(avatarUrl: userChat.chatPhotoUrl),
      trailing: Text(userChat.lastMessageTimestamp == null
          ? ''
          : timeago
              .format(DateTime.fromMillisecondsSinceEpoch(
                  userChat.lastMessageTimestamp!))
              .toString()),
      subtitle: Text(userChat.lastMessage == ''
          ? ''
          : '${userChat.lastMessage.substring(0, min(userChat.lastMessage.length, 16))}...'),
    );
  }
}

class ChatsList extends ConsumerWidget {
  const ChatsList({super.key, required this.chats});
  final List<UserChat?> chats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ChatUIWidget(
          userChat: chats[index]!,
        );
      },
    );
  }
}

class ChatsPage extends ConsumerWidget {
  const ChatsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsStream = ref.watch(chatsStreamProvider);
    return chatsStream.when(
        data: (chats) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Chats'),
                actions: [
                  CreationButton(
                    appBarTitle: 'Create Chat',
                    onSuggestionTapFunc:
                        ref.read(dbRepositoryProvider).createChatWithUser,
                    nextIndex: 1,
                  )
                ],
              ),
              body: chats.isNotEmpty
                  ? ChatsList(
                      chats: chats,
                    )
                  : const NoDataWidget('There are no chats yet'));
        },
        error: (error, stackTrace) => ErrorHandledWidget(error: error),
        loading: () => const DefaultProgressIndicator());
  }
}
