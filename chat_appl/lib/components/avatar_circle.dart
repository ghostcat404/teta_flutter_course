import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.avatarUrl, this.radius = 32.0});

  final String avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return avatarUrl != ''
        ? CachedNetworkImage(
            imageUrl: avatarUrl,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: radius,
              backgroundImage: imageProvider,
              backgroundColor: Colors.transparent,
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage('assets/default_avatar.png'),
            backgroundColor: Colors.transparent,
          );
  }
}
