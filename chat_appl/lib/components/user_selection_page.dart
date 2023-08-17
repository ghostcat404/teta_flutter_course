import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/models/fb_models/user_contact.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({
    super.key,
    required this.appBarTitle,
    required this.dataIsLoaded,
    required this.dbService,
    required this.snapshot,
    required this.function,
  });

  final String appBarTitle;
  final bool dataIsLoaded;
  final FirebaseDatabaseService dbService;
  final Future Function(UserContact?, FirebaseDatabaseService) function;
  final AsyncSnapshot<List<UserContact?>> snapshot;

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  final TextEditingController _searchFieldController = TextEditingController();

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
        ),
        body: widget.dataIsLoaded
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SearchField(
                              onSuggestionTap:
                                  (SearchFieldListItem searchFieldItem) async {
                                await widget.function(
                                    searchFieldItem.item, widget.dbService);
                                Navigator.of(context).push(PageRouteBuilder(
                                    pageBuilder: (context, _, __) =>
                                        const HomePage(
                                          currentPageIndex: 1,
                                        )));
                              },
                              controller: _searchFieldController,
                              suggestions: widget.snapshot.data!
                                  .map((contact) {
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        contact!.contactId) {
                                      return SearchFieldListItem<UserContact?>(
                                          contact.displayName,
                                          item: contact,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              children: [
                                                ProfileAvatar(
                                                    avatarUrl:
                                                        contact.photoUrl),
                                                Text(contact.displayName)
                                              ],
                                            ),
                                          ));
                                    } else {
                                      return SearchFieldListItem('');
                                    }
                                  })
                                  .where((element) => element.searchKey != '')
                                  .toList(),
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () => _searchFieldController.clear(),
                            icon: const Icon(Icons.clear))
                      ],
                    ),
                  ],
                ),
              )
            : const Text('Connection is unavailable'));
  }
}
