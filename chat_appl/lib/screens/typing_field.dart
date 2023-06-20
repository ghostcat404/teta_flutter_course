import 'package:flutter/material.dart';

class TypingField extends StatefulWidget {
  const TypingField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TypingField> createState() => _TypingFieldState();
}

class _TypingFieldState extends State<TypingField> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BottomAppBar(
        child: TextField(
          controller: widget.controller,
          style: const TextStyle(fontSize: 16.0),
          decoration: const InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelText: 'Message',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0)
          )
        )
      ),
    );
  }
}