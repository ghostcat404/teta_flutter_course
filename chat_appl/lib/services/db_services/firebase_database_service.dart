import 'dart:core';

import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_contact.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_appl/services/db_services/services_utils.dart';

import 'package:chat_appl/pages/chats/chat_page.dart';
import 'package:chat_appl/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class FirebaseDatabaseService {
  FirebaseDatabaseService(this.dbInstance);

  final FirebaseDatabase dbInstance;

  Future<UserProfile?> getUserProfile(String userId) async {
    final DataSnapshot profileSnapshot =
        await dbInstance.ref('userProfiles/$userId').get();
    if (profileSnapshot.value != null) {
      return UserProfile.fromJson(
          Map<String, dynamic>.from(profileSnapshot.value! as Map));
    }
    return null;
  }

  Future addOrUpdateUserProfile(String userId, UserProfile userProfile) async {
    final DatabaseReference ref = dbInstance.ref('userProfiles/$userId');
    await ref.set(userProfile.toJson());
  }

  Future addOrUpdateUserInfo(User user) async {
    DatabaseReference ref = dbInstance.ref("users/${user.id}");
    await ref.set(user.toJson());
  }
  // TODO: refactoring ChatInfo and add GROUP CHATS!

  // Future addOrUpdateChatInfo(ChatInfo chatInfo) async {
  //   final DatabaseReference ref =
  //       dbInstance.ref('chatsInfos/${chatInfo.chatId}');
  //   await ref.set(chatInfo.toJson());
  // }

  Future createNewChat(String chatId) async {
    final DatabaseReference chatMessageRef =
        dbInstance.ref('chatsMessages/$chatId');
    final DatabaseReference msgRef = chatMessageRef.child('messages');
    await msgRef.push().set(null);
  }

  Future addOrUpdateUserChat(String userId, UserChat userChat,
      {bool delete = false}) async {
    final DatabaseReference userChatsRef =
        dbInstance.ref('userChats/$userId/${userChat.chatId}');
    userChatsRef.set(delete ? null : userChat.toJson());
  }

  Future<bool> isUserHasChatExists(String userId, String chatId) async {
    final DataSnapshot userChatSnapshot =
        await dbInstance.ref('userChats/$userId/$chatId').get();
    if (userChatSnapshot.value != null) return true;
    return false;
  }

  // Future<ChatInfo?> getChatInfoById(String chatId) async {
  //   DataSnapshot chatsInfoSnapshot =
  //       await dbInstance.ref('chatsInfos/$chatId').get();
  //   if (chatsInfoSnapshot.value != null) {
  //     final ChatInfo chatInfo = ChatInfo.fromJson(
  //         Map<String, dynamic>.from(chatsInfoSnapshot.value as Map));
  //     return chatInfo;
  //   }
  //   return null;
  // }

  Future<String> getUserName(String userId) async {
    final DataSnapshot dataSnapshot =
        await dbInstance.ref('users/$userId/displayName').get();
    return dataSnapshot.value.toString();
  }

  Future<User?> getUser(String userId) async {
    final userSnapshot = await dbInstance.ref().child('users/$userId').get();
    if (userSnapshot.value != null) {
      final currentUser = Map<String, dynamic>.from(userSnapshot.value as Map);
      final user = User.fromJson(currentUser);
      return user;
    }
    return null;
  }

  Future<List<Message?>> getMessageListOnce(String chatId) async {
    final DataSnapshot messagesSnapshot =
        await dbInstance.ref('chatsMessages/$chatId/messages').get();
    final List<Message?> messageList = [];
    if (messagesSnapshot.value != null) {
      final Map<dynamic, dynamic> messages =
          Map<dynamic, dynamic>.from(messagesSnapshot.value! as Map);
      messages.forEach((key, value) {
        final Message? currentMessage = createInstanceOf(
            Map<String, dynamic>.from(value),
            instanceKey: 'chatsMessages');
        messageList.add(currentMessage);
      });
      sortInstancesOf(messageList, instanceKey: 'chatsMessages');
    }
    return messageList;
  }

  Future<UserChat?> getUserChatById(String userId, String chatId) async {
    final userChatSnapshot =
        await dbInstance.ref('userChats/$userId/$chatId').get();
    if (userChatSnapshot.value != null) {
      final userChatJson =
          Map<String, dynamic>.from(userChatSnapshot.value as Map);
      final userChat = UserChat.fromJson(userChatJson);
      return userChat;
    }
    return null;
  }

  Future<UserContact?> getUserContactById(
      String userId, String contactId) async {
    final userContactSnapshot =
        await dbInstance.ref('userContacts/$userId/$contactId').get();
    if (userContactSnapshot.value != null) {
      final userContactJson =
          Map<String, dynamic>.from(userContactSnapshot.value as Map);
      final userContact = UserContact.fromJson(userContactJson);
      return userContact;
    }
    return null;
  }

  Future sendMessage(String text, String userDisplayName, String chatId,
      User user, String contactId) async {
    final User? contact = await getUser(contactId);
    UserChat? userChat = await getUserChatById(user.id, chatId);

    final DatabaseReference chatMessagesRef =
        dbInstance.ref('chatsMessages/$chatId/messages');
    // chatMessagesRef.onChildChanged.
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final messageRef = chatMessagesRef.push();
    final String messageId = messageRef.key!;
    final message = Message(
        messageId: messageId,
        userDisplayName: userDisplayName,
        text: text,
        timestamp: currentTimestamp,
        senderId: user.id);
    await messageRef.set(message.toJson());
    userChat = userChat!.copyWith(
        chatId: chatId,
        chatName: contact!.displayName,
        chatPhotoUrl: contact.photoUrl,
        lastMessage: text,
        lastMessageTimestamp: currentTimestamp);
    await addOrUpdateUserChat(user.id, userChat);
    final UserChat contactChat = userChat.copyWith(chatName: user.displayName);
    await addOrUpdateUserChat(contact.id, contactChat);
  }

  // TODO: refactoring
  Future<List<UserChat?>> getUserChats(String userId) async {
    DataSnapshot userChatsSnapshot =
        await dbInstance.ref('userChats/$userId').get();
    List<UserChat?> userChats = [];
    if (userChatsSnapshot.value != null) {
      final Map<dynamic, dynamic> chats =
          Map<dynamic, dynamic>.from(userChatsSnapshot.value! as Map);
      chats.forEach((key, value) {
        final UserChat? userChat = createInstanceOf(
            Map<String, dynamic>.from(value),
            instanceKey: 'userChats');
        userChats.add(userChat);
      });
    }
    return userChats;
  }

  // TODO: refactoring
  Future<List<UserContact?>> getUserContacts(String userId) async {
    DataSnapshot userContactsSnapshot =
        await dbInstance.ref('userContacts/$userId').get();
    List<UserContact?> userContacts = [];
    if (userContactsSnapshot.value != null) {
      final Map<dynamic, dynamic> contacts =
          Map<dynamic, dynamic>.from(userContactsSnapshot.value! as Map);
      contacts.forEach((key, value) {
        final UserContact? userContact = createInstanceOf(
            Map<String, dynamic>.from(value),
            instanceKey: 'userChats');
        userContacts.add(userContact);
      });
    }
    return userContacts;
  }

  Future createOrUpdateUserContact(String userId, UserContact contact,
      {bool delete = false}) async {
    DatabaseReference userContactRef =
        dbInstance.ref('userContacts/$userId/${contact.contactId}');

    userContactRef.set(delete
        ? null
        : UserContact(
                contactId: contact.contactId,
                displayName: contact.displayName,
                photoUrl: contact.photoUrl)
            .toJson());
  }

  Stream<List<UserChat?>> getUserChatsStream(String userId) =>
      _getStreamByRef('userChats/$userId', cacheKey: 'userChats');

  // Stream<List<ChatInfo?>> getChatInfoStream(String chatId) =>
  //     _getStreamByRef('chatsInfos/$chatId');

  Stream<List<Message?>> getMessageStream(String chatId) =>
      _getStreamByRef('chatsMessages/$chatId/messages');

  Stream<List<UserContact?>> get getUsersStream => _getStreamByRef('users');

  Stream<List<UserContact?>> getContactsStream(String userId) =>
      _getStreamByRef('userContacts/$userId', cacheKey: 'userContacts');

  Stream<List<T?>> _getStreamByRef<T>(String refName, {String? cacheKey}) {
    final String instanceKey = refName.split('/')[0];
    return dbInstance.ref(refName).onValue.map((event) {
      List<T?> dataList = [];
      if (event.snapshot.value != null) {
        final firebaseMessages = Map<dynamic, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        firebaseMessages.forEach((key, value) {
          // Move logic to Repository (different Repositories?)
          final currentData = Map<String, dynamic>.from(value);
          final T? instance =
              createInstanceOf(currentData, instanceKey: instanceKey);
          if (instance != null) cacheInstance<T>(instance, cacheKey: cacheKey);
          dataList.add(instance);
        });
        sortInstancesOf(dataList, instanceKey: instanceKey);
      }
      return dataList;
    });
  }
}

Future createContactWithUser(
    UserContact? contact, FirebaseDatabaseService dbService) async {
  final User? user =
      await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
  dbService.createOrUpdateUserContact(user!.id, contact!);
}

Future deleteContact(
    UserContact contact, FirebaseDatabaseService dbService) async {
  await dbService.createOrUpdateUserContact(
      FirebaseAuth.instance.currentUser!.uid, contact,
      delete: true);
}

Future deleteChat(String currUserId, UserChat userChat,
    FirebaseDatabaseService dbService) async {
  // TODO: add chat duplicating
  // because i want to delete chat
  // only in my account
  await dbService.addOrUpdateUserChat(currUserId, userChat, delete: true);
}

Future createChatWithUser(
    UserContact? contact, FirebaseDatabaseService dbService) async {
  final User? user =
      await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
  // TODO: use the different approach to make a chat id
  final String chatId = calcChatHash(user!.id, contact!.contactId);
  UserChat? userChat = await dbService.getUserChatById(user.id, chatId);
  UserChat? contactChat =
      await dbService.getUserChatById(contact.contactId, chatId);
  final UserChat newUserChat = UserChat(
      chatId: chatId,
      chatName: contact.displayName,
      chatPhotoUrl: contact.photoUrl,
      lastMessage: '',
      contactId: contact.contactId,
      lastMessageTimestamp: null);
  final UserChat newContactChat = newUserChat.copyWith(
      contactId: user.id,
      chatName: user.displayName,
      chatPhotoUrl: user.photoUrl);
  if (userChat == null && contactChat == null) {
    await dbService.addOrUpdateUserChat(user.id, newUserChat);
    await dbService.addOrUpdateUserChat(contact.contactId, newContactChat);
    await dbService.createNewChat(chatId);
  } else {
    if (userChat == null && contactChat != null) {
      await dbService.addOrUpdateUserChat(
          user.id,
          contactChat.copyWith(
              chatName: contact.displayName,
              chatPhotoUrl: contact.photoUrl,
              contactId: contact.contactId));
    }
  }
  final UserContact? contactFromDb =
      await dbService.getUserContactById(user.id, contact.contactId);
  if (contactFromDb == null) {
    createContactWithUser(contact, dbService);
  }
}

Future getOrCreateChatWithUser(
    UserContact contact, FirebaseDatabaseService dbService) async {
  final User? user =
      await dbService.getUser(FirebaseAuth.instance.currentUser!.uid);
  final String chatId = calcChatHash(user!.id, contact.contactId);
  final bool isChatExists =
      await dbService.isUserHasChatExists(user.id, chatId);
  if (!isChatExists) {
    await createChatWithUser(contact, dbService);
  }
  final UserChat? userChat = await dbService.getUserChatById(user.id, chatId);
  return ChatStream(userChat: userChat!, user: user, dbService: dbService);
}
