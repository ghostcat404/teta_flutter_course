import 'package:chat_appl/pages/profile/geo_location_page.dart';
import 'package:chat_appl/providers/firebase_providers/firebase_providers.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileSettingsPage extends ConsumerWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  await ref.read(dbRepositoryProvider).clearAllCache();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('All cached data have cleared!')));
                }),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Share profile'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(
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
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GeolocatorWidget())),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              onTap: () async {
                await ref.watch(firebaseAuthProvider).signOut();
                Navigator.of(context).pushNamed('/sign-in');
              },
            ),
          ),
        ]),
      ),
    );
  }
}
