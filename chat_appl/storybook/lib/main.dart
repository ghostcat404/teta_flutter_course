import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/avatar_circle.dart';
import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:chat_appl/screens/dialog_screen.dart';

void main() => runApp(const MyApp());

final _plugins = initializePlugins(
  contentsSidePanel: true,
  knobsSidePanel: true,
  initialDeviceFrameData: DeviceFrameData(
    device: Devices.ios.iPhone13,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Storybook(
        initialStory: 'Screens/Scaffold',
        plugins: _plugins,
        stories: [
          Story(
            name: 'Message from messageList',
            builder: (context) {
              final String userId = context.knobs.text(label: 'userId', initial: 'aaaaaaaaaaaaa');
              final String text = context.knobs.text(label: 'Message', initial: 'message');
              final int timestamp = context.knobs.sliderInt(
                label: 'timestamp',
                min: 1285537005517,
                max: 1785537005517,
              );
              return MessagesView(messageList: [Message(userId: userId, text: text, timestamp: timestamp)]);
            }
          ),
          Story(
            name: 'Avatar component',
            builder: (context) {
              final bool hasAvatar = context.knobs.boolean(label: 'Has Avatar flag', initial: true);
              final String photoUrl = context.knobs.text(label: 'photoUrl', initial: 'https://as2.ftcdn.net/v2/jpg/00/97/58/97/1000_F_97589769_t45CqXyzjz0KXwoBZT9PRaWGHRk5hQqQ.jpg');
              return Center(child: ProfileAvatar(hasAvatar: hasAvatar, avatarUrl: photoUrl));
            }
          ),
        ],
      );
}