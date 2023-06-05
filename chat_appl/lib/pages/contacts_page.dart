import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

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
      body: ListView(
        children: const <Widget>[
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('John Doe'),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('John Doe'),
          ),
          ListTile(
            leading: CircleAvatar(child: Text('A')),
            title: Text('John Doe'),
          ),
        ],
      ),
    );
  }
}