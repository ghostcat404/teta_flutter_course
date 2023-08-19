import 'dart:core';

import 'package:chat_appl/models/fb_models/chat_info.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user_chat.dart';
import 'package:chat_appl/models/fb_models/user_profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat_appl/services/db_services/services_utils.dart';

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

  Future<T?> getModelByRef<T>(String ref) async {
    final DataSnapshot snapshot = await dbInstance.ref(ref).get();
    if (snapshot.value != null) {
      return createInstanceOf<T>(
          Map<String, dynamic>.from(snapshot.value! as Map));
    }
    return null;
  }

  Future addOrUpdateModelByRef(dynamic model, String ref) async {
    final DatabaseReference reference = dbInstance.ref(ref);
    await reference.set(model?.toJson());
  }

  Future<List<T?>> getModelsListByRef<T>(String ref) async {
    final DataSnapshot snapshot = await dbInstance.ref(ref).get();
    final List<T?> tList = [];
    if (snapshot.value != null) {
      final Map<dynamic, dynamic> listOfJsons =
          Map<dynamic, dynamic>.from(snapshot.value! as Map);
      listOfJsons.forEach((key, json) {
        final T? model = createInstanceOf<T>(
          Map<String, dynamic>.from(json),
        );
        tList.add(model);
      });
      sortInstancesOf<T>(tList);
    }
    return tList;
  }

  Stream<List<T?>> getStreamOfListOfModelsByRef<T>(String refName) {
    return dbInstance.ref(refName).onValue.map((event) {
      List<T?> dataList = [];
      if (event.snapshot.value != null) {
        final firebaseMessages = Map<dynamic, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        firebaseMessages.forEach((key, value) {
          // Move logic to Repository (different Repositories?)
          final currentData = Map<String, dynamic>.from(value);
          final T? instance = createInstanceOf<T>(currentData);
          // if (instance != null) cacheInstance<T>(instance, cacheKey: cacheKey);
          dataList.add(instance);
        });
        sortInstancesOf<T>(dataList);
      }
      return dataList;
    });
  }

  Future addOrUpdateUserChat(
      String userId, String chatId, UserProfile? contact) async {
    final DatabaseReference userChatsRef =
        dbInstance.ref('userChats/$userId/$chatId');
    UserChat? userChat;
    if (contact != null) {
      final DataSnapshot chatInfoDataSnapshot =
          await dbInstance.ref('chatInfos/$chatId').get();
      if (chatInfoDataSnapshot.value != null) {
        final ChatInfo chatInfo = ChatInfo.fromJson(
            Map<String, dynamic>.from(chatInfoDataSnapshot.value! as Map));
        userChat = UserChat(
            chatId: chatId,
            chatName: contact.displayName,
            chatPhotoUrl: contact.photoUrl,
            contactId: contact.userId,
            lastMessage: chatInfo.lastMessage,
            lastMessageTimestamp: chatInfo.lastMessageTimestamp);
      }
    }
    userChatsRef.set(userChat?.toJson());
  }

  Future sendMessage(String text, UserProfile userProfile, String chatId,
      String contactId) async {
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final String userChatStrRef = 'userChats/${userProfile.userId}/$chatId';
    final String contactChatStrRef = 'userChats/$contactId/$chatId';
    final String chatInfoStrRef = 'chatInfos/$chatId';
    final String chatMessagesStrRef = 'chatsMessages/$chatId/messages';

    final DatabaseReference chatMessagesRef =
        dbInstance.ref(chatMessagesStrRef);

    UserChat? userChat = await getModelByRef<UserChat>(userChatStrRef);
    UserChat? contactChat = await getModelByRef<UserChat>(contactChatStrRef);
    final ChatInfo? chatInfo = await getModelByRef<ChatInfo>(chatInfoStrRef);

    final messageRef = chatMessagesRef.push();
    final String messageId = messageRef.key!;
    final String userMessageStrRef =
        'userChatsMessages/${userProfile.userId}/$chatId/messages/$messageId';
    final String contactMessageStrRef =
        'userChatsMessages/$contactId/$chatId/messages/$messageId';
    final DatabaseReference userMessagesRef = dbInstance.ref(userMessageStrRef);
    final DatabaseReference contactMessagesRef =
        dbInstance.ref(contactMessageStrRef);

    final message = Message(
        messageId: messageId,
        userDisplayName: userProfile.displayName,
        text: text,
        timestamp: currentTimestamp,
        senderId: userProfile.userId);
    final Map<String, dynamic> jsonMessage = message.toJson();
    await messageRef.set(jsonMessage);
    await userMessagesRef.set(jsonMessage);
    await contactMessagesRef.set(jsonMessage);

    await addOrUpdateModelByRef(
        chatInfo!.copyWith(
            lastMessage: message.text, lastMessageTimestamp: currentTimestamp),
        chatInfoStrRef);
    await addOrUpdateModelByRef(
        userChat!.copyWith(
            lastMessage: text, lastMessageTimestamp: currentTimestamp),
        userChatStrRef);
    await addOrUpdateModelByRef(
        contactChat!.copyWith(
            lastMessage: text, lastMessageTimestamp: currentTimestamp),
        contactChatStrRef);
  }

  Future<String> createNewChat() async {
    // First Chat creation
    final DatabaseReference chatInfosRef = dbInstance.ref('chatInfos').push();
    final String chatId = chatInfosRef.key!;
    final ChatInfo chatInfo = ChatInfo(chatId: chatId, lastMessage: '');
    await chatInfosRef.set(chatInfo.toJson());
    return chatId;
  }

  // у обоих пользователей нет чатов
  Future createChatWithUser(String currUserId, UserProfile contact) async {
    String? chatId = await getChatIdFromContact(currUserId, contact);
    final UserProfile? currUserProfile =
        await getModelByRef<UserProfile>('userProfiles/$currUserId');
    chatId ??= await createNewChat();
    await addOrUpdateUserChat(currUserId, chatId, contact);
    await addOrUpdateUserChat(contact.userId, chatId, currUserProfile!);
  }

  // у контакта есть чат с нами
  Future<String?> getChatIdFromContact(
      String currUserId, UserProfile contact) async {
    final List<UserChat?> contactChats =
        await getModelsListByRef<UserChat>('userChats/$currUserId');
    String? chatId;
    for (UserChat? contactChat in contactChats) {
      if (contactChat?.contactId == currUserId) {
        chatId = contactChat?.chatId;
        break;
      }
    }
    return chatId;
  }
}
