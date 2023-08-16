import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/models/user_chat.dart';
import 'package:chat_appl/models/user_contact.dart';
import 'package:chat_appl/services/db_services/database_service.dart';
import 'package:chat_appl/services/mappers/model_convertation_mappers.dart';
import 'package:get_it/get_it.dart';

// TODO: add ENUMS instead of Strings?

void sortInstancesOf(List<dynamic> dataList, {required instanceKey}) {
  final factories = <String, void Function(List<dynamic>)>{
    'chatsMessages': (List<dynamic> dataList) {
      dataList.sort((b, a) => a.timestamp.compareTo(b.timestamp));
    },
    'userContacts': (List<dynamic> dataList) {
      dataList.sort((a, b) => a.displayName.compareTo(b.displayName));
    },
    'chatInfos': (List<dynamic> dataList) {
      dataList.sort(
          (b, a) => a.lastMessageTimestamp.compareTo(b.lastMessageTimestamp));
    },
    'users': (dataList) => dataList,
    'userChats': (dataList) => dataList,
  };

  final instance = factories[instanceKey];
  instance!.call(dataList);
}

dynamic createInstanceOf(Map<String, dynamic> json, {required instanceKey}) {
  final factories = <String, dynamic Function(Map<String, dynamic>)>{
    'users': (Map<String, dynamic> json) =>
        toUserContactFromUser(User.fromJson(json)),
    'userContacts': (Map<String, dynamic> json) => UserContact.fromJson(json),
    'chatsMessages': (Map<String, dynamic> json) => Message.fromJson(json),
    'chatInfos': (Map<String, dynamic> json) => ChatInfo.fromJson(json),
    'userChats': (Map<String, dynamic> json) => UserChat.fromJson(json),
  };

  final instance = factories[instanceKey];
  return instance?.call(json);
}

void cacheInstance<T>(T? instance, {String? cacheKey}) {
  final LocalDatabaseService localDbInstance =
      GetIt.instance<LocalDatabaseService>();

  final factories = <String, void Function(T?)>{
    'userContacts': (dynamic instance) async =>
        await localDbInstance.cacheUserContact(instance),
    'userChats': (dynamic instance) async =>
        await localDbInstance.cacheUserChat(instance),
    'null': (dynamic instance) async {}
  };
  cacheKey ??= 'null';
  final action = factories[cacheKey];
  action?.call(instance);
}
