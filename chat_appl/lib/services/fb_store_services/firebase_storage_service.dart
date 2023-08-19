import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseStorageService {
  final FirebaseStorage storageInstance;

  FirebaseStorageService(this.storageInstance);

  Future<String> addOrUpdateUserProfilePhotoUrl(
      File imageFile, String imageName, String userId) async {
    final Reference ref = storageInstance.ref('images/$userId/$imageName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}
