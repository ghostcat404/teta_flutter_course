import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'default_providers.g.dart';

@riverpod
class TextController extends _$TextController {
  @override
  TextEditingController build({String? text}) {
    final TextEditingController controller = TextEditingController(text: text);
    ref.onDispose(() => controller.dispose());
    return controller;
  }

  void clear() => state.clear();
}
