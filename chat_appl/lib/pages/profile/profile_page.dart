import 'dart:io';

import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/pages/settings/settings_profile.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// TODO: refactoring
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user, required this.dbService});

  final User? user;
  final FirebaseDatabaseService dbService;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _avatarURL = '';
  final TextEditingController _controller = TextEditingController();
  String _displayName = '';
  bool _isEdit = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _loadName();
  }

  _loadAvatar() {
    final String avatarUrl = widget.user!.photoUrl;
    if (avatarUrl != '') {
      setState(() {
        _avatarURL = avatarUrl;
      });
    }
  }

  _loadName() {
    final String displayName = widget.user!.displayName;
    setState(() {
      _displayName = displayName;
    });
  }

  void _edit() {
    setState(() {
      _isEdit = true;
    });
  }

  void _done() async {
    final String displayName = await _updateProfileName();
    setState(() {
      _displayName = displayName;
      _isEdit = false;
    });
    _controller.text = '';
  }

  Future<String> _updateProfileName() async {
    final User? currUser =
        await widget.dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    late String displayName;
    displayName = _controller.text != '' ? _controller.text : _displayName;
    widget.dbService.addOrUpdateUserInfo(User(
      id: currUser!.id,
      displayName: displayName,
      photoUrl: currUser.photoUrl,
    ));
    return displayName;
  }

  void _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var imageFile = File(image!.path);
    Reference ref =
        FirebaseStorage.instance.ref().child('images').child(image.name);
    await ref.putFile(imageFile);
    final downloadURL = await ref.getDownloadURL();

    widget.dbService.addOrUpdateUserInfo(User(
      id: widget.user!.id,
      displayName: widget.user!.displayName,
      photoUrl: downloadURL,
    ));
    _loadAvatar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(PageRouteBuilder(pageBuilder: (context, _, __) {
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
                  onTap: _updateProfileImage,
                  child: ProfileAvatar(
                    avatarUrl: _avatarURL,
                    radius: 64.0,
                  )),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _isEdit
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 64.0),
                        child: TextField(
                          controller: _controller,
                        ),
                      ),
                    )
                  : Text(
                      _displayName,
                      style: const TextStyle(fontSize: 32.0),
                    ),
              _isEdit
                  ? IconButton(
                      iconSize: 28.0,
                      onPressed: _done,
                      icon: const Icon(Icons.done))
                  : IconButton(
                      iconSize: 28.0,
                      onPressed: _edit,
                      icon: const Icon(Icons.edit_rounded),
                    ),
            ]),
          ],
        ),
      ),
    );
  }
}
