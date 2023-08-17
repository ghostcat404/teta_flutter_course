import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_providers.g.dart';

@riverpod
class ConnectionState extends _$ConnectionState {
  Future<bool> _checkConnection() async {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none ? false : true;
  }

  @override
  Future<bool> build() async {
    return await _checkConnection();
  }
}
