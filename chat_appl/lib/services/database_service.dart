import 'package:chat_appl/models/chat_info.dart';
import 'package:chat_appl/models/chat_settings.dart';
import 'package:chat_appl/models/db_user.dart';
import 'package:chat_appl/models/message.dart';
import 'package:chat_appl/models/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

class DatabaseService {
  final FirebaseDatabase dbInstance;

  DatabaseService({required this.dbInstance});

  Future addOrUpdateUserInfo(User user) async {
    DatabaseReference ref = dbInstance.ref("users/${user.id}");
    await ref.set(user.toJson());
  }

  Future addOrUpdateUserChatsInfo(String userId, ChatInfo chatInfo) async {
    DatabaseReference ref =
        dbInstance.ref('users/$userId/chatsInfo/${chatInfo.chatId}');
    await ref.set(chatInfo.toJson());
  }

  Future createNewChat(String chatId, ChatSettings chatSettings) async {
    final DatabaseReference dbRef = dbInstance.ref('chats/$chatId');
    await dbRef.set(chatSettings.toJson());
    final DatabaseReference msgRef = dbRef.child('messages');
    msgRef.push().set(null);
  }

  Future<ChatInfo?> getUserChatsInfo(String userAId, String chatId) async {
    DataSnapshot chatsInfoSnapshot =
        await dbInstance.ref('users/$userAId/chatsInfo/$chatId').get();
    if (chatsInfoSnapshot.value != null) {
      final ChatInfo chatInfo = ChatInfo.fromJson(
          Map<String, dynamic>.from(chatsInfoSnapshot.value as Map));
      return chatInfo;
    }
    return null;
  }

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
    final DataSnapshot messagesSnapshot = await dbInstance.ref('chats/$chatId/messages').get();
    final Map<dynamic, dynamic> messages = Map<dynamic, dynamic>.from(messagesSnapshot.value! as Map);
    final List<Message?> messageList = [];
    if (messagesSnapshot.value != null) {
      messages.forEach((key, value) {
          final Message? currentMessage = createInstanceOf<Message>(Map<String, dynamic>.from(value));
          messageList.add(currentMessage);
      });
      sortInstancesOf<Message>(messageList);
    }
    return messageList;
  }

  Future sendMessage(String text, String userDisplayName, String chatId) async {
    final DatabaseReference chatDbRef = dbInstance.ref('chats/$chatId');
    final DatabaseReference usersRef = dbInstance.ref('users');

    final DataSnapshot chatSettingsSnapshot = await chatDbRef.get();
    final ChatSettings chatSettings = ChatSettings.fromJson(
        Map<String, dynamic>.from(chatSettingsSnapshot.value! as Map));

    final DatabaseReference refUserA = usersRef.child(chatSettings.userAId);
    final DatabaseReference refUserB = usersRef.child(chatSettings.userBId);
    final DataSnapshot snapshotUserA = await refUserA.get();
    final DataSnapshot snapshotUserB = await refUserB.get();
    final User userA =
        User.fromJson(Map<String, dynamic>.from(snapshotUserA.value! as Map));
    final User userB =
        User.fromJson(Map<String, dynamic>.from(snapshotUserB.value! as Map));

    final DataSnapshot snapshotChatInfoUserA =
        await refUserA.child('chatsInfo/$chatId').get();
    final DataSnapshot snapshotChatInfoUserB =
        await refUserB.child('chatsInfo/$chatId').get();
    final ChatInfo chatInfoUserA = ChatInfo.fromJson(
        Map<String, dynamic>.from(snapshotChatInfoUserA.value! as Map));
    final ChatInfo chatInfoUserB = ChatInfo.fromJson(
        Map<String, dynamic>.from(snapshotChatInfoUserB.value! as Map));

    final DatabaseReference chatMessagesRef = chatDbRef.child('messages');
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final message = Message(
        userDisplayName: userDisplayName,
        text: text,
        timestamp: currentTimestamp);
    final messageRef = chatMessagesRef.push();
    await messageRef.set(message.toJson());
    await addOrUpdateUserChatsInfo(
        userA.id,
        ChatInfo(
            chatId: chatId,
            userBId: userB.id,
            chatName: chatInfoUserA.chatName,
            lastMessage: text,
            lastMessageTimestamp: currentTimestamp));
    await addOrUpdateUserChatsInfo(
        userB.id,
        ChatInfo(
            chatId: chatId,
            userBId: userA.id,
            chatName: chatInfoUserB.chatName,
            lastMessage: text,
            lastMessageTimestamp: currentTimestamp));
  }

  Stream<List<ChatInfo?>> getChatInfoStream(String userId) =>
      _getStreamByRef('/users/$userId/chatsInfo');
  Stream<List<Message?>> getMessageStream(String chatId) =>
      _getStreamByRef<Message>('chats/$chatId/messages');
  Stream<List<User?>> get contactsStream => _getStreamByRef<User>('users');

  Stream<List<T?>> _getStreamByRef<T>(String refName) {
    return dbInstance.ref(refName).onValue.map((event) {
      // TODO: use it if connection is on but there is no values
      List<T?> dataList = [];
      if (event.snapshot.value != null) {
        final firebaseMessages = Map<dynamic, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        firebaseMessages.forEach((key, value) {
          final currentData = Map<String, dynamic>.from(value);
          final T? instance = createInstanceOf<T>(currentData);
          if (instance != null) cacheInstanceOf<T>(instance);
          dataList.add(instance);
        });
        sortInstancesOf<T>(dataList);
      }
      return dataList;
    });
  }
}

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
      final isarUser = DbUser()
        ..userId = localUser.id
        ..displayName = localUser.displayName
        ..photoUrl = localUser.photoUrl;
      await isarDb.writeTxn(() async => await isarDb.dbUsers.put(isarUser));
    },
    Message: (dynamic message) async {},
    ChatInfo: (dynamic message) async {},
  };

  final action = factories[T];
  action?.call(instance);
}
