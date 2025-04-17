import 'package:resort_web_app/config/service_locator.dart';
import 'package:resort_web_app/models/room_model.dart';

import '../services/firebase_service.dart';

class RoomRepository {
  final service = serviceLocator.get<FirebaseService>();

  addRoom(RoomModel room) async {
    return await service.addRoom(room);
  }

  editRoom(RoomModel room) async {
    return await service.editRoom(room);
  }

  Future<List<RoomModel>> fetchAllRooms() async {
    return await service.fetchAllRooms();
  }

  deleteRoom(String roomNo) async {
    await service.deleteRoom(roomNo);
  }

  updateGroupStatus(String roomNumber, bool status) async {
    await service.updateGroupStatus(roomNumber, status);
  }
}
