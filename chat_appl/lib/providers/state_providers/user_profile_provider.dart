import 'dart:io';

import 'package:chat_appl/models/db_models/db_user_settings.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';
import 'package:chat_appl/providers/db_providers/db_providers.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:image_picker/image_picker.dart';
part 'user_profile_provider.g.dart';

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  Future _fetchUserProfile() async {
    state = null;
    final DatabaseRepository dbRepository = ref.watch(dbRepositoryProvider);
    final String? currUserId = ref.watch(authStateChangesProvider);
    final UserSettings? userSettings =
        await dbRepository.getModelByIdOrRef<UserSettings, DbUserSettings>(
            currUserId!, 'userSettings/$currUserId');
    if (userSettings != null) {
      state = userSettings;
      return;
    } else {
      final UserSettings? cachedUserSettings = await ref
          .read(localDbServiceProvider)
          .getModelById<UserSettings, DbUserSettings>(currUserId);
      if (cachedUserSettings != null) {
        state = cachedUserSettings;
        return;
      } else {
        // при первом заходе
        final UserSettings newUserSettings = UserSettings(
            userId: currUserId,
            displayName: currUserId.substring(0, 8),
            photoUrl: '');
        await dbRepository.addOrUpdateModelByRef(
            'userSettings/$currUserId', newUserSettings);
        await dbRepository.addOrUpdateModelByRef(
            'userProfiles/$currUserId',
            UserProfile(
                userId: currUserId,
                displayName: newUserSettings.displayName,
                photoUrl: newUserSettings.photoUrl));
        await dbRepository
            .cacheModel<UserSettings, DbUserSettings>(newUserSettings);
        state = newUserSettings;
        return;
      }
    }
  }

  @override
  UserSettings? build() {
    Future(_fetchUserProfile);
    return null;
  }

  Future updateDisplayName(String newDisplayName) async {
    final UserSettings currentProfile = state!;
    final UserSettings newSettings = currentProfile.copyWith(
        displayName: newDisplayName, isNameEditing: false);
    await _updateProfileOnChange(newSettings);
  }

  void startEditing() {
    state = state!.copyWith(isNameEditing: true);
  }

  Future updateProfileImage() async {
    final UserSettings currentSettings = state!;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var imageFile = File(image!.path);
    final String newPhotoUrl = await ref
        .read(firebaseStorageServiceProvider)!
        .addOrUpdateUserProfilePhotoUrl(
            imageFile, image.name, currentSettings.userId);
    final UserSettings newSettings =
        currentSettings.copyWith(photoUrl: newPhotoUrl);
    await _updateProfileOnChange(newSettings);
  }

  Future _updateProfileOnChange(UserSettings newSettings) async {
    final DatabaseRepository dbRepository =
        await ref.watch(dbRepositoryProvider);
    await dbRepository.updateUserSettings(newSettings);
    await dbRepository.cacheModel<UserSettings, DbUserSettings>(newSettings);
    await _fetchUserProfile();
  }
}
