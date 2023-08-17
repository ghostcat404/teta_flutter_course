import 'dart:io';

import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/providers/default_providers.dart';
import 'package:chat_appl/providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers.dart';
import 'package:chat_appl/services/repository/database_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:image_picker/image_picker.dart';
part 'user_profile_provider.g.dart';

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  Future<UserProfile> _fetchUserProfile() async {
    final DatabaseRepository? dbRepository =
        await ref.watch(dbRepositoryProvider.future);
    final String? currUserId =
        ref.watch(authStateChangesProvider.select((value) => value));
    bool connIsAvailableFlg = await ref.watch(connectionStateProvider.future);
    UserProfile? userProfile =
        await dbRepository!.getUserProfile(currUserId!, connIsAvailableFlg);
    if (userProfile != null) {
      return userProfile;
    }
    return UserProfile(userId: currUserId, displayName: '', photoUrl: '');
  }

  @override
  FutureOr<UserProfile> build() async {
    return await _fetchUserProfile();
  }

  Future updateDisplayName(String newDisplayName) async {
    final UserProfile currentProfile = state.value!;
    final UserProfile newProfile = currentProfile.copyWith(
        displayName: newDisplayName, isNameEditing: false);
    await ref
        .watch(firebaseDbServiceProvider)!
        .addOrUpdateUserProfile(currentProfile.userId, newProfile);
    await updateProfileOnChange();
  }

  Future startEditing() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await Future.value(state.value!.copyWith(isNameEditing: true));
    });
  }

  Future updateProfileImage() async {
    final UserProfile currentProfile = state.value!;

    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var imageFile = File(image!.path);
    final String newPhotoUrl = await ref
        .watch(firebaseStorageServiceProvider)!
        .addOrUpdateUserProfilePhotoUrl(
            imageFile, image.name, currentProfile.userId);
    final UserProfile newProfile =
        currentProfile.copyWith(photoUrl: newPhotoUrl);
    await ref
        .watch(firebaseDbServiceProvider)!
        .addOrUpdateUserProfile(currentProfile.userId, newProfile);
    await updateProfileOnChange();
  }

  Future updateProfileOnChange() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _fetchUserProfile();
    });
  }
}
