import 'dart:io';

import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/pages/avatar_circle.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';// Import for Android features.
// Import for iOS features.

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late DatabaseService dbService;

  String _avatarURL = '';
  final TextEditingController _controller = TextEditingController();
  String _displayName = '';
  bool _isAvatar = false;
  bool _isEdit = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<DatabaseService>();
    super.initState();
    _loadAvatar();
    _loadName();
  }

  _loadAvatar() async {
    final User? currUser = await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    final String avatarUrl = currUser!.photoUrl;
    if (avatarUrl != '') {
      setState(() {
        _isAvatar = true;
        _avatarURL = avatarUrl;
      });
    }
  }

  _loadName() async {
    final User? currUser = await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    final String displayName = currUser!.displayName;
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/sign-in');
  }

  Future<String> _updateProfileName() async {
    late String displayName;
    if (_controller.text != '') {
      displayName = _controller.text;
      dbService.updateUserDisplayName(displayName);
    } else {
      displayName = FirebaseAuth.instance.currentUser!.uid;
    }
    return displayName;
  }

  void _updateProfileImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var imageFile = File(image!.path);
    Reference ref = FirebaseStorage.instance.ref().child('images').child(image.name);
    await ref.putFile(imageFile);
    final downloadURL = await ref.getDownloadURL();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoUrl', downloadURL);
    dbService.addOrUpdateUserInfo(
      User(
        id: prefs.getString('uuid')!,
        displayName: prefs.getString('displayName')!,
        photoUrl: prefs.getString('photoUrl')!
      )
    );
    _loadAvatar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, _, __) => Scaffold(
                    appBar: AppBar(title: const Text('Share profile'),),
                    body: Column(
                      children: [
                        Center(
                          child: QrImageView(
                            data: FirebaseAuth.instance.currentUser!.uid,
                            version: QrVersions.auto,
                            size: 300.0,
                          ),
                        ),
                        const SizedBox(height: 16.0,),
                        TextButton(onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: FirebaseAuth.instance.currentUser!.uid));
                        }, child: const Text('Copy to clipborad'))
                      ],
                    ),
                  ),
                )
              );
            },
            icon: const Icon(Icons.qr_code)
          ),
          _isEdit 
            ? TextButton(onPressed: _done, child: const Text('Done'))
            : TextButton(onPressed: _edit, child: const Text('Edit')),
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
              onTap: _updateProfileImage,
              child: ProfileAvatar(hasAvatar: _isAvatar, avatarUrl: _avatarURL,)
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WebViewContainer())
              ),
              child: const Text('Web view example')
            ),
            TextButton(
              onPressed: _signOut,
              child: const Text('Sign Out')
            ),
            const SizedBox(
              height: 16.0,
            ),
            _isEdit
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64.0),
                  child: TextField(
                    controller: _controller,
                  ),
                )
              : Text(
                _displayName,
                style: const TextStyle(fontSize: 24.0),
              ),
          ],
        ),
      ),
    );
  }
}


class WebViewContainer extends StatefulWidget {
  const WebViewContainer({super.key});

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..loadRequest(Uri.parse('https://flutter.dev'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: controller))
        ],
      ),
    );
  }
}