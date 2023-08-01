import 'dart:io';

import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/components/avatar_circle.dart';
import 'package:chat_appl/pages/home_page.dart';
import 'package:chat_appl/pages/settings/geo_location_page.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/db_services/firebase_database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart'; // Import for Android features.
// Import for iOS features.

class SettingsPage extends StatefulWidget {
  final User? user;

  const SettingsPage({super.key, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late FirebaseDatabaseService dbService;

  String _avatarURL = '';
  final TextEditingController _controller = TextEditingController();
  String _displayName = '';
  bool _isAvatar = false;
  bool _isEdit = false;
  bool isDropDowned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final GetIt getIt = GetIt.instance;
    dbService = getIt<FirebaseDatabaseService>();
    super.initState();
    _loadAvatar();
    _loadName();
  }

  _loadAvatar() async {
    final User? currUser =
        await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    final String avatarUrl = currUser!.photoUrl;
    if (avatarUrl != '') {
      setState(() {
        _isAvatar = true;
        _avatarURL = avatarUrl;
      });
    }
  }

  _loadName() async {
    final User? currUser =
        await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
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
    final User? currUser =
        await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
    late String displayName;
    displayName = _controller.text != '' ? _controller.text : _displayName;
    dbService.addOrUpdateUserInfo(User(
      id: currUser!.id,
      displayName: displayName,
      photoUrl: currUser.photoUrl,
    ));
    return displayName;
  }

  void _updateProfileImage() async {
    final User? currUser =
        await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);

    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var imageFile = File(image!.path);
    Reference ref =
        FirebaseStorage.instance.ref().child('images').child(image.name);
    await ref.putFile(imageFile);
    final downloadURL = await ref.getDownloadURL();

    dbService.addOrUpdateUserInfo(User(
      id: currUser!.id,
      displayName: currUser.displayName,
      photoUrl: downloadURL,
    ));
    _loadAvatar();
  }

  Future<void> clearAllCache() async =>
      await LocalDatabaseService(isarDbInstance: GetIt.instance<Isar>())
          .clearAllCache();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: move actions to separate widget
      appBar: AppBar(title: const Text('Settings'), actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton(
                borderRadius: BorderRadius.circular(32.0),
                items: [
                  DropdownMenuItem(
                    alignment: AlignmentDirectional.center,
                    value: 'clear_cache',
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (context, _, __) =>
                                      FutureBuilder(
                                          future: clearAllCache(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              Navigator.of(context).pop();
                                              return const HomePage(
                                                currentPageIndex: 2,
                                              );
                                            }
                                            return Scaffold(
                                                appBar: AppBar(
                                                  title: const Text('Settings'),
                                                ),
                                                body: const Column(
                                                  children: [
                                                    Center(
                                                        child: Text(
                                                            'Cache deleting is in progress')),
                                                    Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ],
                                                ));
                                          })));
                              clearAllCache;
                            },
                            icon: const Icon(Icons.cleaning_services)),
                        const Text('Clear Cache')
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    alignment: AlignmentDirectional.center,
                    value: 'qr_code',
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, _, __) => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Share profile'),
                                  ),
                                  body: Column(
                                    children: [
                                      Center(
                                        child: QrImageView(
                                          data: FirebaseAuth
                                              .instance.currentUser!.uid,
                                          version: QrVersions.auto,
                                          size: 300.0,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      TextButton(
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: FirebaseAuth.instance
                                                        .currentUser!.uid));
                                          },
                                          child:
                                              const Text('Copy to clipborad'))
                                    ],
                                  ),
                                ),
                              ));
                            },
                            icon: const Icon(Icons.qr_code)),
                        const Text('Share')
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    alignment: AlignmentDirectional.center,
                    value: 'geo_location',
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => Navigator.of(context).push(
                                PageRouteBuilder(
                                    pageBuilder: (context, _, __) =>
                                        const GeolocatorWidget())),
                            icon: const Icon(Icons.location_on_outlined)),
                        const Text('Location')
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                      alignment: AlignmentDirectional.center,
                      value: 'sign_out',
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: _signOut,
                              icon: const Icon(Icons.exit_to_app)),
                          const Text('Sign Out')
                        ],
                      )),
                ],
                onChanged: (value) => setState(() {}),
                icon: const Icon(Icons.settings),
                iconSize: 24.0,
                alignment: AlignmentDirectional.center,
                onTap: () {},
              ),
            ),
          ),
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
                    hasAvatar: _isAvatar,
                    avatarUrl: _avatarURL,
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        style: const TextStyle(fontSize: 16.0),
                      ),
                _isEdit
                    ? IconButton(onPressed: _done, icon: const Icon(Icons.done))
                    : IconButton(
                        onPressed: _edit,
                        icon: const Icon(Icons.edit_rounded),
                      ),
              ],
            ),
            TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const WebViewContainer())),
                child: const Text('Web view example')),
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
        children: [Expanded(child: WebViewWidget(controller: controller))],
      ),
    );
  }
}
