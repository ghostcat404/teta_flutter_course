// import 'dart:io';

// import 'package:chat_appl/models/fb_models/user.dart';
// import 'package:chat_appl/components/avatar_circle.dart';
// import 'package:chat_appl/pages/settings/settings_profile.dart';
// import 'package:chat_appl/services/db_services/firebase_database_service.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide User;
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/pages/settings/settings_profile.dart';
import 'package:chat_appl/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserProfile> userProfile =
        ref.watch(userProfileNotifierProvider);
    return userProfile.when(
        error: (err, stack) => Text('Error: $err'),
        loading: () => const DefaultProgressIndicator(),
        data: (profile) => Scaffold(
              appBar: AppBar(title: const Text('Profile'), actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            PageRouteBuilder(pageBuilder: (context, _, __) {
                          return const ProfileSettingsPage();
                        }));
                      },
                      icon: const Icon(Icons.settings)),
                )
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
                            avatarUrl: profile.photoUrl,
                            radius: 64.0,
                          )),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      profile.isNameEditing
                          ? Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 64.0),
                                child: TextField(
                                  autofocus: true,
                                  controller: _controller,
                                ),
                              ),
                            )
                          : Text(
                              profile.displayName,
                              style: const TextStyle(fontSize: 32.0),
                            ),
                      profile.isNameEditing
                          ? IconButton(
                              iconSize: 28.0,
                              onPressed: () async => await ref
                                  .read(userProfileNotifierProvider.notifier)
                                  .updateDisplayName(_controller.text),
                              icon: const Icon(Icons.done))
                          : IconButton(
                              iconSize: 28.0,
                              onPressed: () async => await ref
                                  .read(userProfileNotifierProvider.notifier)
                                  .startEditing(),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                    ]),
                  ],
                ),
              ),
            ));
  }
}
