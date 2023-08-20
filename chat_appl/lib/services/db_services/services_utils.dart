import 'package:chat_appl/models/db_models/db_message.dart';
import 'package:chat_appl/models/db_models/db_user_chat.dart';
import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/fb_models/chat_info.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';

void _sortByLastMessageTimestamp(List<dynamic> dataList) {
  dataList.sort((b, a) {
    if (a.lastMessageTimestamp == null) {
      return 1;
    }
    if (b.lastMessageTimestamp == null) {
      return -1;
    }
    return a.lastMessageTimestamp.compareTo(b.lastMessageTimestamp);
  });
}

void _sortByTimestamp(List<dynamic> dataList) =>
    dataList.sort((b, a) => a.timestamp.compareTo(b.timestamp));

void _sortByDisplayName(List<dynamic> dataList) =>
    dataList.sort((a, b) => a.displayName.compareTo(b.displayName));

void sortInstancesOf<T>(
  List<dynamic> dataList,
) {
  final factories = <Type, void Function(List<dynamic>)>{
    Message: (List<dynamic> dataList) => _sortByTimestamp(dataList),
    DbMessage: (List<dynamic> dataList) => _sortByTimestamp(dataList),
    UserProfile: (List<dynamic> dataList) => _sortByDisplayName(dataList),
    DbUserProfile: (List<dynamic> dataList) => _sortByDisplayName(dataList),
    UserChat: (List<dynamic> dataList) => _sortByLastMessageTimestamp(dataList),
    DbUserChat: (List<dynamic> dataList) =>
        _sortByLastMessageTimestamp(dataList),
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
