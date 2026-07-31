import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static Stream<bool> get onStatusChange {
    return Connectivity().onConnectivityChanged.map(
      (result) => !result.contains(ConnectivityResult.none),
    );
  }
}