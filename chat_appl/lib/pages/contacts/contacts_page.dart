import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/components/buttons/default_buttons.dart';
import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/pages/contacts/contact_widgets.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:chat_appl/providers/stream_providers/stream_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ContactsList extends ConsumerWidget {
  const ContactsList({super.key, required this.contacts});
  final List<UserProfile?> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currUserId = ref.watch(authStateChangesProvider);
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final UserProfile? contact = contacts[index];
          if (contact!.userId != currUserId) {
            return Slidable(
              key: ValueKey(contact.userId),
              endActionPane:
                  ActionPane(motion: const ScrollMotion(), children: <Widget>[
                SlidableAction(
                  onPressed: (context) {
                    ref.watch(dbRepositoryProvider).createOrUpdateUserContact(
                        currUserId!, contact.userId, null);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                )
              ]),
              child: ListTile(
                leading: ProfileAvatar(
                  avatarUrl: contact.photoUrl,
                ),
                title: Text(contact.displayName),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ContactCard(contactId: contact.userId))),
              ),
            );
          }
          return null;
        });
  }
}

class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsStream = ref.watch(contactsStreamProvider);
    return contactsStream.when(
        data: (contacts) => Scaffold(
            appBar: AppBar(
              title: const Text('Contacts'),
              actions: [
                CreationButton(
                  appBarTitle: 'Create Contact',
                  onSuggestionTapFunc:
                      ref.read(dbRepositoryProvider).createOrUpdateUserContact,
                )
              ],
            ),
            body: contacts.isNotEmpty
                ? ContactsList(contacts: contacts)
                : const NoDataWidget('There are no contacts yet')),
        error: (error, stackTrace) => ErrorHandledWidget(error: error),
        loading: () => const DefaultProgressIndicator());
  }
}
