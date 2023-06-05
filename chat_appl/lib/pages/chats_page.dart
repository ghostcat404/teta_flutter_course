import 'package:flutter/material.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView(
        children: const <Widget>[
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('John Doe'),
            subtitle: Text('Hello!'),
            trailing: Text('31.05.2023'),
          ),
          Divider(height: 0),
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('John Doe'),
            subtitle: Text('Hello!'),
            trailing: Text('31.05.2023'),
          ),
          Divider(height: 0),
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('John Doe'),
            subtitle: Text('Hello!'),
            trailing: Text('31.05.2023'),
          ),
          Divider(height: 0),
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('John Doe'),
            subtitle: Text('Hello!'),
            trailing: Text('31.05.2023'),
          ),
          Divider(height: 0),
        ],
      ),
    );
  }
}