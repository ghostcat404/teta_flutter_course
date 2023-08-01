import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/services/firebase_database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ContactsPage extends StatefulWidget {
  final User? user;

  const ContactsPage({super.key, required this.user});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late FirebaseDatabaseService dbService;

  @override
  void initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<FirebaseDatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
        ),
        body: StreamBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return snapshot.data!.isNotEmpty
                  ? ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        final User? user = snapshot.data![index];
                        bool hasAvatar = false;
                        if (user!.photoUrl != '') {
                          hasAvatar = true;
                        }
                        return ListTile(
                          leading: ProfileAvatar(
                            hasAvatar: hasAvatar,
                            avatarUrl: user.photoUrl,
                          ),
                          title: Text(user.displayName),
                        );
                      })
                  : const Text('No Contacts');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: Colors.blueGrey, size: 32.0),
                  )
                ],
              );
            }
          },
          stream: dbService.contactsStream,
        ));
  }
}
