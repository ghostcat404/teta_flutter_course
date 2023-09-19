import 'package:chat_appl/models/db_models/db_message.dart';
import 'package:chat_appl/models/fb_models/message.dart';
import 'package:chat_appl/models/fb_models/user_settings.dart';
import 'package:chat_appl/providers/repository_providers/repository_providers.dart';
import 'package:chat_appl/providers/state_providers/user_profile_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_page_provider.g.dart';

@riverpod
class ChatPageState extends _$ChatPageState {
  Future _fetchChatMessages(String chatId) async {
    state = null;
    final List<Message?> listMessages = await ref
        .watch(dbRepositoryProvider)
        .getListOfModels<Message, DbMessage>('chatsMessages/$chatId/messages');
    state = listMessages;
  }

  Future sendMessage(String text, String chatId, String contactId) async {
    final UserSettings? userSettings =
        await ref.read(userProfileNotifierProvider);
    await ref
        .watch(dbRepositoryProvider)
        .sendMessage(text, userSettings!.userId, chatId, contactId);
    Future(() => _fetchChatMessages(chatId));
  }

  @override
  List<Message?>? build({required String chatId}) {
    Future(() => _fetchChatMessages(chatId));
    return null;
  }
}
