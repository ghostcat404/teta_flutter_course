import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';
import 'package:chat_appl/pages/settings/settings_profile.dart';
import 'package:chat_appl/providers/default_providers.dart';
import 'package:chat_appl/providers/state_providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettings? settings = ref.watch(userProfileNotifierProvider);
    final controller = ref.watch(textControllerProvider(
        text: settings == null ? '' : settings.displayName));
    return settings == null
        ? const DefaultProgressIndicator()
        : Scaffold(
            appBar: AppBar(title: const Text('Profile'), actions: [
              settings.isNameEditing
                  ? IconButton(
                      onPressed: () async {
                        await ref
                            .read(userProfileNotifierProvider.notifier)
                            .updateDisplayName(controller.text);
                      },
                      icon: const Icon(Icons.done))
                  : IconButton(
                      onPressed: () => ref
                          .read(userProfileNotifierProvider.notifier)
                          .startEditing(),
                      icon: const Icon(Icons.edit_rounded),
                    ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const ProfileSettingsPage();
                    }));
                  },
                  icon: const Icon(Icons.settings)),
            ]),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                        onTap: () async => await ref
                            .read(userProfileNotifierProvider.notifier)
                            .updateProfileImage(),
                        child: ProfileAvatar(
                          avatarUrl: settings.photoUrl,
                          radius: 64.0,
                        )),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    settings.isNameEditing
                        ? Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 64.0),
                              child: TextField(
                                autofocus: true,
                                controller: controller,
                              ),
                            ),
                          )
                        : Text(
                            settings.displayName,
                            style: const TextStyle(fontSize: 32.0),
                          ),
                  ]),
                ],
              ),
            ),
          );
  }
}
