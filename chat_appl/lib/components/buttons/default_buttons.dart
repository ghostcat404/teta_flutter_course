import 'package:chat_appl/components/user_selection_page.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:flutter/material.dart';

class CreationButton extends StatelessWidget {
  const CreationButton(
      {super.key,
      required this.appBarTitle,
      required this.onSuggestionTapFunc,
      this.nextIndex = 0});
  final String appBarTitle;
  final Future Function(String, String, UserProfile) onSuggestionTapFunc;
  final int nextIndex;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SelectionPage(
                appBarTitle: appBarTitle,
                onSuggestionTapFunc: onSuggestionTapFunc,
                pushedPage: HomePage(
                  initialIndex: nextIndex,
                ))));
      },
    );
  }
}
