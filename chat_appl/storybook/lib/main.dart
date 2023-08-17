import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

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
        stories: const [],
        // stories: [
        //   Story(
        //       name: 'Message from messageList',
        //       builder: (context) {
        //         final String userId = context.knobs
        //             .text(label: 'userId', initial: 'aaaaaaaaaaaaa');
        //         final String text =
        //             context.knobs.text(label: 'Message', initial: 'message');
        //         final int timestamp = context.knobs.sliderInt(
        //           label: 'timestamp',
        //           min: 1285537005517,
        //           max: 1785537005517,
        //         );
        //         return ChatPage(
        //           messageList: [
        //             Message(
        //                 userDisplayName: userId,
        //                 text: text,
        //                 timestamp: timestamp)
        //           ],
        //           chatId: '',
        //           user: const User(
        //               id: 'id',
        //               displayName: 'displayName',
        //               photoUrl: 'photoUrl'),
        //         );
        //       }),
        //   Story(
        //       name: 'Avatar component',
        //       builder: (context) {
        //         final bool hasAvatar = context.knobs
        //             .boolean(label: 'Has Avatar flag', initial: true);
        //         final String photoUrl = context.knobs.text(
        //             label: 'photoUrl',
        //             initial:
        //                 'https://as2.ftcdn.net/v2/jpg/00/97/58/97/1000_F_97589769_t45CqXyzjz0KXwoBZT9PRaWGHRk5hQqQ.jpg');
        //         return Center(
        //             child: ProfileAvatar(
        //                 hasAvatar: hasAvatar, avatarUrl: photoUrl));
        //       }),
        //   Story(
        //       name: 'Message shimmer',
        //       builder: (context) {
        //         return Scaffold(
        //           appBar: AppBar(
        //             title: const Text('Chat with user'),
        //           ),
        //           body: const Padding(
        //             padding: EdgeInsets.all(8.0),
        //             child: Center(child: MessageWidgetShimmer()),
        //           ),
        //         );
        //       }),
        //   Story(
        //       name: 'Message List Shimmer',
        //       builder: (context) {
        //         return const ListMessagesShimmer();
        //       })
        // ],
      );
}
