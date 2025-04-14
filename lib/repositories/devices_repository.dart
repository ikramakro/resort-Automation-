import 'package:resort_web_app/config/service_locator.dart';
import 'package:resort_web_app/services/firebase_service.dart';

class DevicesRepository {
  static DevicesRepository? _instance;

  final _firebaseService = serviceLocator.get<FirebaseService>();

  DevicesRepository._();

  factory DevicesRepository() => _instance ??= DevicesRepository._();

  fetchRoomDevices(String roomNo) async {
    return await _firebaseService.fetchDevices(roomNo);
  }

  updateDeviceStatus(String roomNo, String deviceId, String status) async {
    return await _firebaseService.updateDeviceStatus(roomNo, deviceId, status);
  }
}
