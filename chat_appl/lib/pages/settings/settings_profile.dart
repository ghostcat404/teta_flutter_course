import 'package:chat_appl/pages/profile/geo_location_page.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  Future<void> clearAllCache() async =>
      await GetIt.instance<LocalDatabaseService>().clearAllCache();

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          Card(
            child: ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: const Text('Clear all cache'),
                onTap: () async {
                  await clearAllCache();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('All cached data have cleared!')));
                }),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Share profile'),
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, _, __) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Share profile'),
                    ),
                    body: Column(
                      children: [
                        Center(
                          child: QrImageView(
                            data: FirebaseAuth.instance.currentUser!.uid,
                            version: QrVersions.auto,
                            size: 300.0,
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextButton(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      FirebaseAuth.instance.currentUser!.uid));
                            },
                            child: const Text('Copy to clipborad'))
                      ],
                    ),
                  ),
                ));
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Show GeoLocation'),
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, _, __) => const GeolocatorWidget())),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              onTap: () async => await _signOut(),
            ),
          ),
        ]),
      ),
    );
  }
}
