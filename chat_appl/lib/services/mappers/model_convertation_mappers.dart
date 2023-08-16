import 'package:chat_appl/models/db_message.dart';
import 'package:chat_appl/models/db_user.dart';
import 'package:chat_appl/models/db_user_chat.dart';
import 'package:chat_appl/models/db_user_contact.dart';
import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:chat_appl/models/user_chat.dart';
import 'package:chat_appl/models/user_contact.dart';

User toUserFromDbUser(DbUser dbUser) {
  return User(
    id: dbUser.userId,
    displayName: dbUser.displayName,
    photoUrl: dbUser.photoUrl,
  );
}

DbUser toDbUserFromUser(User user) {
  return DbUser(
      userId: user.id, displayName: user.displayName, photoUrl: user.photoUrl);
}

DbMessage toDbMessageFromMessage(Message message) {
  return DbMessage(
      messageId: message.messageId,
      text: message.text,
      timestamp: message.timestamp,
      userDisplayName: message.userDisplayName,
      senderId: message.senderId);
}

Message toMessageFromDbMessage(DbMessage dbMessage) {
  return Message(
      messageId: dbMessage.messageId,
      text: dbMessage.text,
      timestamp: dbMessage.timestamp,
      userDisplayName: dbMessage.userDisplayName,
      senderId: dbMessage.senderId);
}

UserContact toUserContactFromDbUserContact(DbUserContact dbUserContact) {
  return UserContact(
      contactId: dbUserContact.contactId,
      displayName: dbUserContact.displayName,
      photoUrl: dbUserContact.photoUrl);
}

DbUserContact toDbUserContactFromUserContact(UserContact userContact) {
  return DbUserContact(
      contactId: userContact.contactId,
      displayName: userContact.displayName,
      photoUrl: userContact.photoUrl);
}

UserChat toUserChatFromDbUserChat(DbUserChat dbUserChat) {
  return UserChat(
      chatId: dbUserChat.chatId,
      chatName: dbUserChat.chatName,
      chatPhotoUrl: dbUserChat.chatPhotoUrl,
      lastMessage: dbUserChat.lastMessage,
      contactId: dbUserChat.contactId,
      lastMessageTimestamp: dbUserChat.lastMessageTimestamp);
}

DbUserChat toDbUserChatFromUserChat(UserChat userChat) {
  return DbUserChat(
      chatId: userChat.chatId,
      chatName: userChat.chatName,
      chatPhotoUrl: userChat.chatPhotoUrl,
      lastMessage: userChat.lastMessage,
      contactId: userChat.contactId,
      lastMessageTimestamp: userChat.lastMessageTimestamp);
}

UserContact toUserContactFromUser(User user) {
  return UserContact(
      contactId: user.id,
      displayName: user.displayName,
      photoUrl: user.photoUrl);
}
