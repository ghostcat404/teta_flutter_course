import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatDetailsScreen extends ConsumerWidget {
  const ChatDetailsScreen({super.key, required this.userChat});

  final UserChat userChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currUserId = ref.watch(authStateChangesProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat Details'),
        ),
        body: BaseSizedBoxColumn(children: [
          NamePhotoCard(
            name: userChat.chatName,
            photoUrl: userChat.chatPhotoUrl,
          ),
          Padding(
              padding: const EdgeInsets.all(24.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CustomButtonWidget(
                  icon: const Icon(Icons.delete_forever),
                  buttonName: 'Delete Chat',
                  onTapFunction: () async {
                    ref
                        .read(dbRepositoryProvider)
                        .deleteChat(currUserId!, userChat);
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                        (r) => false);
                  },
                ),
                const SizedBox(
                  width: 64.0,
                ),
                CustomButtonWidget(
                  icon: const Icon(Icons.delete_forever),
                  buttonName: 'Clear Chat',
                  onTapFunction: () async {
                    ref
                        .read(dbRepositoryProvider)
                        .clearChat(currUserId!, userChat);
                    Navigator.of(context).pop();
                  },
                )
              ]))
        ]));
  }
}
