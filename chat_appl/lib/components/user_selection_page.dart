import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/components/default_widgets.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/providers/default_providers.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/stream_providers/stream_providers.dart';
import 'package:chat_appl/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:searchfield/searchfield.dart';

// Future selectUserToCreate(
//     BuildContext context,
//     WidgetRef ref,
//     Future Function(String, String, UserProfile) onSuggestionTapFunc,
//     String appBarTitle) async {
// }

class UsersSearchField extends ConsumerWidget {
  const UsersSearchField(
      {super.key, required this.onSuggestionTapFunc, required this.pushedPage});

  final Future Function(String, String, UserProfile) onSuggestionTapFunc;
  final Widget pushedPage;

  void actionFunc(UserProfile item, BuildContext context, WidgetRef ref) async {
    final String? currUserId = ref.watch(authStateChangesProvider);
    await onSuggestionTapFunc(currUserId!, item.userId, item);
    pushPageAndRemoveAll(context, pushedPage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(profilesStreamProvider);
    return usersStream.when(
        data: (profiles) {
          final TextEditingController controller =
              ref.watch(textControllerProvider());
          final String? currUserId = ref.watch(authStateChangesProvider);
          return SearchField(
            onSuggestionTap: (SearchFieldListItem searchFieldItem) {
              actionFunc(searchFieldItem.item, context, ref);
            },
            controller: controller,
            suggestions: profiles
                .map((profile) {
                  if (currUserId! != profile!.userId) {
                    return SearchFieldListItem<UserProfile?>(
                        profile.displayName,
                        item: profile,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            children: [
                              ProfileAvatar(avatarUrl: profile.photoUrl),
                              Text(profile.displayName)
                            ],
                          ),
                        ));
                  } else {
                    return SearchFieldListItem('');
                  }
                })
                .where((element) => element.searchKey != '')
                .toList(),
          );
        },
        error: (error, stackTrace) => ErrorHandledWidget(error: error),
        loading: () => const DefaultProgressIndicator());
  }
}

class SelectionPage extends ConsumerWidget {
  const SelectionPage(
      {super.key,
      required this.appBarTitle,
      required this.onSuggestionTapFunc,
      required this.pushedPage});

  final String appBarTitle;
  final Future Function(String, String, UserProfile) onSuggestionTapFunc;
  final Widget pushedPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller =
        ref.watch(textControllerProvider());
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UsersSearchField(
                      onSuggestionTapFunc: onSuggestionTapFunc,
                      pushedPage: pushedPage,
                    )),
              ),
              IconButton(
                  onPressed: () => controller.clear(),
                  icon: const Icon(Icons.clear))
            ],
          ),
        ));
  }
}
