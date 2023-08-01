import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_settings.freezed.dart';
part 'chat_settings.g.dart';

@freezed
class ChatSettings with _$ChatSettings {
  const factory ChatSettings({
    required String chatId,
    required String userAId,
    required String userBId
  }) = _ChatSettings;

  factory ChatSettings.fromJson(Map<String, dynamic> json) => _$ChatSettingsFromJson(json);
}