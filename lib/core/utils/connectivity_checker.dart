import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityChecker {
  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static Future<bool> isOnMobileData() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }

  static Future<bool> isSlowConnection() async {
    final isMobile = await isOnMobileData();
    if (isMobile) return true;
    return false;
  }
}