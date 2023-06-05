import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isEdit = false;
  bool _isAvatar = false;
  String _avatarURL = '';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  _loadAvatar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? avatarURL = prefs.getString('avatarURL');
    if (avatarURL != null) {
      setState(() {
        _isAvatar = true;
        _avatarURL = avatarURL;
      });
    }
  }

  void _edit() {
    setState(() {
      _isEdit = true;
    });
  }

  void _done() {
    setState(() {
      _isEdit = false;
    });
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var imageFile = File(image!.path);
    Reference ref = FirebaseStorage.instance.ref().child('images').child(image.name);
    await ref.putFile(imageFile);
    final downloadURL = await ref.getDownloadURL();
    // print(downloadURL);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarURL', downloadURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          _isEdit 
            ? TextButton(onPressed: _done, child: const Text('Done'))
            : TextButton(onPressed: _edit, child: const Text('Edit'))
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 64.0,
            ),
            GestureDetector(
              onTap: pickImage,
              child: const CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage('assets/default_avatar.png'), // _isAvatar ? Image.network(_avatarURL) : SEE cached_image_network
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            _isEdit
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 64.0),
                  child: TextField(),
                )
              : const Text(
                'no_name',
                style: TextStyle(fontSize: 24.0),
              ),
          ],
        ),
      ),
    );
  }
}