import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';

/// FNV-1a 64bit hash algorithm optimized for Dart Strings
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

String calcChatHash(String id, String idOther) {
  return md5
      .convert(
          utf8.encode(id.compareTo(idOther) == 1 ? idOther + id : id + idOther))
      .toString();
}

Future<bool> checkConnection() async {
  final ConnectivityResult connectivityResult =
      await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.none ? false : true;
}
