import 'package:chat_appl/models/fb_models/chat_info.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';

// TODO: add ENUMS instead of Strings?

void sortInstancesOf<T>(
  List<dynamic> dataList,
) {
  final factories = <Type, void Function(List<dynamic>)>{
    Message: (List<dynamic> dataList) {
      dataList.sort((b, a) => a.timestamp.compareTo(b.timestamp));
    },
    UserProfile: (List<dynamic> dataList) {
      dataList.sort((a, b) => a.displayName.compareTo(b.displayName));
    },
    UserChat: (List<dynamic> dataList) {
      dataList.sort((b, a) {
        if (a.lastMessageTimestamp == null) {
          return 1;
        }
        if (b.lastMessageTimestamp == null) {
          return -1;
        }
        return a.lastMessageTimestamp.compareTo(b.lastMessageTimestamp);
      });
    },
    UserSettings: (dataList) => dataList,
    User: (dataList) => dataList,
  };

  final instance = factories[T];
  instance!.call(dataList);
}

T? createInstanceOf<T>(Map<String, dynamic> json) {
  final factories = <Type, dynamic Function(Map<String, dynamic>)>{
    UserProfile: (Map<String, dynamic> json) => UserProfile.fromJson(json),
    UserSettings: (Map<String, dynamic> json) => UserSettings.fromJson(json),
    Message: (Map<String, dynamic> json) => Message.fromJson(json),
    ChatInfo: (Map<String, dynamic> json) => ChatInfo.fromJson(json),
    UserChat: (Map<String, dynamic> json) => UserChat.fromJson(json),
    User: (Map<String, dynamic> json) => User.fromJson(json),
  };

  final instance = factories[T]?.call(json);
  return instance;
}

// void cacheInstance<T>(T? instance, {String? cacheKey}) {
//   final LocalDatabaseService localDbInstance =
//       GetIt.instance<LocalDatabaseService>();

//   final factories = <String, void Function(T?)>{
//     // 'userContacts': (dynamic instance) async =>
//     //     await localDbInstance.cacheItem<UserContact, DbUserContact>(instance),
//     // 'userChats': (dynamic instance) async =>
//     //     await localDbInstance.cacheItem<UserChat, DbUserChat>(instance),
//     // 'chatsMessages': (dynamic instance) async =>
//     //     await localDbInstance.cacheItem<Message, DbMessage>(instance),
//     'null': (dynamic instance) async {}
//   };
//   cacheKey ??= 'null';
//   final action = factories[cacheKey];
//   action?.call(instance);
// }
