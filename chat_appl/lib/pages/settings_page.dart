import 'dart:io';

import 'package:chat_appl/pages/avatar_circle.dart';
import 'package:chat_appl/services/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  late final WebViewController _webViewController;

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
    
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

      _webViewController = controller;
  }

  _loadAvatar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? avatarUrl = prefs.getString('photoUrl');
    if (avatarUrl != null && avatarUrl != '') {
      setState(() {
        _isAvatar = true;
        _avatarURL = avatarUrl;
      });
    } else {
      await prefs.setString('photoUrl', '');
    }
  }

  _loadName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? prefsDisplayName = prefs.getString('displayName');
    late String displayName;
    if (prefsDisplayName == null) {
      displayName = prefs.getString('uuid')!.substring(0, 8);
      dbService.addOrUpdateUserInfo(displayName: displayName);
    } else {
      displayName = prefsDisplayName;
    }
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
    late String displayName;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_controller.text != '') {
      prefs.setString('displayName', _controller.text);
      displayName = _controller.text;
      dbService.addOrUpdateUserInfo(displayName: displayName);
    } else {
      displayName = prefs.getString('displayName')!;
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
    dbService.addOrUpdateUserInfo(photoUrl: downloadURL);
    _loadAvatar();
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
              onTap: _updateProfileImage,
              child: ProfileAvatar(hasAvatar: _isAvatar, avatarUrl: _avatarURL,)
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextButton(
              onPressed: () => Scaffold(
                backgroundColor: Colors.green,
                appBar: AppBar(
                  title: const Text('Flutter WebView example'),
                ),
                body: WebViewWidget(controller: _webViewController),
              ),
              child: const Text('Web view example')
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