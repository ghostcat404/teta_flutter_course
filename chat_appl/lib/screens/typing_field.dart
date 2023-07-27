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

class _TypingFieldState extends State<TypingField> with SingleTickerProviderStateMixin {
  late DatabaseService dbService;
  late SharedPreferences prefs;

  late final AnimationController _sendButtonAnimationController;

  @override
  void dispose() {
    _sendButtonAnimationController.dispose();
    super.dispose();
  }

  @override
  initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<DatabaseService>();
    _loadPrefs();

    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      upperBound: 1.0,
      vsync: this
    )..addListener(() {
      setState(() {});
    });

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
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_sendButtonAnimationController),
              child: IconButton(
                onPressed: () {
                  _sendButtonAnimationController.forward(from: 0);
                  // TODO: fix!
                  dbService.sendMessage(widget.controller.text, prefs.getString('uuid')!);
                  widget.controller.text = '';
                },
                icon: const Icon(Icons.send),
                color: Colors.blue[900],
              ),
            )
          ],
        )
      ),
    );
  }
}