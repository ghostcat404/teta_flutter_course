import 'package:chat_appl/pages/chats/dialog_screen.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:chat_appl/shimmers/chats_shimmers.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late DatabaseService dbService;

  @override
  void initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const CircleAvatar(child: Text('A')),
            title: const Text('John Doe'),
            subtitle: const Text('Hello!'),
            trailing: const Text('31.05.2023'),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  settings: const RouteSettings(
                    name: '/test-chat'
                  ),
                  pageBuilder: (context, _, __) => StreamBuilder(
                    builder: (context, snapshot) {
                      bool dataIsLoaded = (
                        snapshot.hasData
                        && snapshot.data != null
                        && snapshot.data!.isNotEmpty
                      );
                      return AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        child: dataIsLoaded
                          ? MessagesView(messageList: snapshot.data!)
                          : const ListMessagesShimmer(),
                      );
                    },
                    stream: dbService.messageStream,
                  ),
                  transitionsBuilder: (context, animation, _, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }
}