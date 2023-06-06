import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  final DatabaseService dbService;

  const ContactsPage({super.key, required this.dbService});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: StreamBuilder(
        builder: (context, snapshot) {
          if (
            snapshot.hasData
            && snapshot.data != null
            && snapshot.data!.isNotEmpty
          ) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (BuildContext context, int index) {
                final User user = snapshot.data![index];
                bool hasAvatar = false;
                if (user.photoUrl != '') {
                  hasAvatar = true;
                }
                return ListTile(
                  leading: hasAvatar
                    ? CachedNetworkImage(
                        imageUrl: user.photoUrl,
                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                          CircularProgressIndicator(value: downloadProgress.progress),
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 32,
                          backgroundImage: imageProvider,
                          backgroundColor: Colors.transparent,
                        ),
                      )
                    : const CircleAvatar(
                        radius: 32,
                        backgroundImage: AssetImage('assets/default_avatar.png'),
                        backgroundColor: Colors.transparent,
                      ),
                  title: Text(user.displayName),
                );
              }
            );
          } else {
            return const Text('No Contacts');
          }
        },
        stream: widget.dbService.contactsStream,
      )
    );
  }
}