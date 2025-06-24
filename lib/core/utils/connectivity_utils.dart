import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  /// Cek apakah device terhubung ke internet
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Cek apakah bisa akses internet
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Cek apakah device online (WiFi atau Mobile Data)
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Listener untuk perubahan koneksi
  static Stream<List<ConnectivityResult>> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }
}
