import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_page_provider.g.dart';

@Riverpod(keepAlive: true)
class HomePageState extends _$HomePageState {
  @override
  int build(int initialIndex) {
    return initialIndex;
  }

  void moveToAnotherPage(int pageIndex) {
    state = pageIndex;
  }
}
