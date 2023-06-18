import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final bool hasAvatar;
  final String avatarUrl;
  const ProfileAvatar({super.key, required this.hasAvatar, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return hasAvatar
      ? CachedNetworkImage(
          imageUrl: avatarUrl,
          progressIndicatorBuilder: (context, url, downloadProgress) => 
            CircularProgressIndicator(value: downloadProgress.progress),
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 32,
            backgroundImage: imageProvider,
            backgroundColor: Colors.transparent,
          ),
        )
      : const CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage('assets/default_avatar.png'),
          backgroundColor: Colors.transparent,
        );
  }
}