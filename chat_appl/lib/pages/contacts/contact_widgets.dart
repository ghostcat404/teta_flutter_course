import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:chat_appl/providers/state_providers/contact_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactCard extends ConsumerWidget {
  const ContactCard({super.key, required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currUserId = ref.watch(authStateChangesProvider);
    final UserProfile? contact = ref.watch(contactPageStateProvider(contactId));
    return contact == null
        ? const DefaultProgressIndicator()
        : Scaffold(
            appBar: AppBar(title: const Text('Contact Info')),
            body: BaseSizedBoxColumn(
              children: [
                NamePhotoCard(
                    photoUrl: contact.photoUrl, name: contact.displayName),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButtonWidget(
                        icon: const Icon(Icons.message),
                        buttonName: 'Message',
                        onTapFunction: () async {
                          // TODO: get or create
                          final UserChat? userChat = await ref
                              .read(dbRepositoryProvider)
                              .getOrCreateChatByContactId(
                                  currUserId!, contact.userId);
                          if (userChat != null) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatPage(
                                    chat: userChat,
                                    contactId: contact.userId)));
                          }
                        },
                      ),
                      CustomButtonWidget(
                        icon: const Icon(Icons.delete_forever),
                        buttonName: 'Delete User',
                        onTapFunction: () async {
                          await ref
                              .read(dbRepositoryProvider)
                              .createOrUpdateUserContact(
                                  currUserId!, contactId, contact);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const HomePage(
                                    initialIndex: 0,
                                  )));
                        },
                      ),
                      CustomButtonWidget(
                        icon: const Icon(Icons.more_horiz),
                        buttonName: 'More',
                        onTapFunction: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Hey! You are the best!')));
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
