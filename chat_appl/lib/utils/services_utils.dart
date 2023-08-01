import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/db_user.dart';
import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

void sortInstancesOf<T>(List<dynamic> dataList) {
  final factories = <Type, void Function(List<dynamic>)>{
    Message: (List<dynamic> dataList) {
      dataList.sort((b, a) => a.timestamp.compareTo(b.timestamp));
    },
    User: (List<dynamic> dataList) {
      dataList.sort((a, b) => a.displayName.compareTo(b.displayName));
    },
    ChatInfo: (List<dynamic> dataList) => dataList,
  };

  final instance = factories[T];
  instance!.call(dataList);
}

T? createInstanceOf<T>(Map<String, dynamic> json) {
  final factories = <Type, T Function(Map<String, dynamic>)>{
    User: (Map<String, dynamic> json) => User.fromJson(json) as T,
    Message: (Map<String, dynamic> json) => Message.fromJson(json) as T,
    ChatInfo: (Map<String, dynamic> json) => ChatInfo.fromJson(json) as T
  };

  final instance = factories[T];
  return instance?.call(json);
}

void cacheInstanceOf<T>(T instance) {
  final Isar isarDb = GetIt.instance<Isar>();

  final factories = <Type, void Function(dynamic)>{
    User: (dynamic localUser) async {
      final isarUser = DbUser(
          userId: localUser.id,
          displayName: localUser.displayName,
          photoUrl: localUser.photoUrl);
      await isarDb.writeTxn(() async => await isarDb.dbUsers.put(isarUser));
    },
    Message: (dynamic message) async {},
    ChatInfo: (dynamic message) async {},
  };

  final action = factories[T];
  action?.call(instance);
}
