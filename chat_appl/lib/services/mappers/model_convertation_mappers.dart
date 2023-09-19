import 'package:chat_appl/models/db_models/db_message.dart';
import 'package:chat_appl/models/db_models/db_user_chat.dart';
import 'package:chat_appl/models/db_models/db_user_profile.dart';
import 'package:chat_appl/models/db_models/db_user_settings.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';

T? convertModelGetter<E, T>(E model) {
  final factories = <Type, T Function(E)>{
    UserSettings: (dynamic model) => DbUserSettings(
        userId: model.userId,
        displayName: model.displayName,
        photoUrl: model.photoUrl) as T,
    DbUserSettings: (dynamic model) => UserSettings(
        userId: model.userId,
        displayName: model.displayName,
        photoUrl: model.photoUrl) as T,
    UserProfile: (dynamic model) => DbUserProfile(
          userId: model.userId,
          displayName: model.displayName,
          photoUrl: model.photoUrl,
        ) as T,
    DbUserProfile: (dynamic model) => UserProfile(
          userId: model.userId,
          displayName: model.displayName,
          photoUrl: model.photoUrl,
        ) as T,
    Message: (dynamic model) => DbMessage(
        messageId: model.messageId,
        chatId: model.chatId,
        text: model.text,
        timestamp: model.timestamp,
        userDisplayName: model.userDisplayName,
        senderId: model.senderId,
        indexId: model.chatId) as T,
    DbMessage: (dynamic model) => Message(
        messageId: model.messageId,
        text: model.text,
        timestamp: model.timestamp,
        userDisplayName: model.userDisplayName,
        senderId: model.senderId,
        chatId: model.chatId) as T,
    UserChat: (dynamic model) => DbUserChat(
        chatId: model.chatId,
        chatName: model.chatName,
        chatPhotoUrl: model.chatPhotoUrl,
        lastMessage: model.lastMessage,
        contactId: model.contactId,
        lastMessageTimestamp: model.lastMessageTimestamp) as T,
    DbUserChat: (dynamic model) => UserChat(
        chatId: model.chatId,
        chatName: model.chatName,
        chatPhotoUrl: model.chatPhotoUrl,
        lastMessage: model.lastMessage,
        contactId: model.contactId,
        lastMessageTimestamp: model.lastMessageTimestamp) as T,
  };

  final action = factories[E];
  return action?.call(model);
}
