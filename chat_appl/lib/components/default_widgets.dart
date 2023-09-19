import 'package:chat_appl/components/avatar_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget(this.displayText, {super.key});

  final String displayText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Text(displayText))],
      ),
    );
  }
}

class BaseSizedBoxColumn extends StatelessWidget {
  const BaseSizedBoxColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(children: children));
  }
}

class NamePhotoCard extends StatelessWidget {
  const NamePhotoCard({super.key, required this.photoUrl, required this.name});

  final String name;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileAvatar(
                  avatarUrl: photoUrl,
                  radius: 50,
                ),
                SelectableText(
                  name,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class DefaultProgressIndicator extends StatelessWidget {
  const DefaultProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorHandledWidget extends StatelessWidget {
  const ErrorHandledWidget({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget(
      {super.key,
      required this.icon,
      required this.buttonName,
      this.onTapFunction});

  final Function()? onTapFunction;
  final String buttonName;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      heroTag: buttonName,
      onPressed: onTapFunction,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon, Text(buttonName)],
      ),
    );
  }
}

class DefaultActionPane extends StatelessWidget {
  const DefaultActionPane({super.key, required this.deleteAction});
  final Function() deleteAction;

  @override
  Widget build(BuildContext context) {
    return ActionPane(motion: const ScrollMotion(), children: <Widget>[
      SlidableAction(
        onPressed: (context) => deleteAction,
        backgroundColor: const Color(0xFFFE4A49),
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      )
    ]);
  }
}
