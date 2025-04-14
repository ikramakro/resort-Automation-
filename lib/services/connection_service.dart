// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectionService {
  static InternetConnectionService? _instance;

  InternetConnectionService._();

  factory InternetConnectionService() =>
      _instance ??= InternetConnectionService._();

  hasInternetConnection() async {
    final List<ConnectivityResult> connectivityResult =
        //.........CHECK IF THE DEVICE IS CONNECTED TO WIFI OR ETHERNET RETURN TURE ELSE FALSE
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      log('device has internet');
      return true;
    }
    // _showNoInternetMessage();
    log('device does not have internet');
    return false;
  }
}
