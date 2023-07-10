import 'package:chat_appl/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TypingField extends StatefulWidget {
  const TypingField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TypingField> createState() => _TypingFieldState();
}

class _TypingFieldState extends State<TypingField> {
  late DatabaseService dbService;
  late SharedPreferences prefs;
  bool isSending = false;

  @override
  initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<DatabaseService>();
    _loadPrefs();
    super.initState();
  }

  _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                style: const TextStyle(fontSize: 16.0),
                decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)
                )
              ),
            ),
            IconButton(
              onPressed: () {
                dbService.sendMessage(widget.controller.text, prefs.getString('uuid')!);
                widget.controller.text = '';
              },
              icon: const Icon(Icons.send)
            )
          ],
        )
      ),
    );
  }
}