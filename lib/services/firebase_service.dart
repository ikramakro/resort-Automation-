import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resort_web_app/models/notification_model.dart';

import '../models/device_model.dart';
import '../models/room_model.dart';

class FirebaseService {
  static FirebaseService? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const roomsCollection = 'Rooms';

  FirebaseService._();

  factory FirebaseService() => _instance ??= FirebaseService._();

  Future<void> addRoom(RoomModel room) async {
    try {
      final roomRef = _firestore
          .collection(roomsCollection)
          .doc('Room No. ${room.roomNumber}');

      roomRef.set({
        'Name': room.roomName,
        'roomNumber': room.roomNumber,
        'groupValue': room.groupCurrentStatus,
      });
      for (var i = 0; i < room.devices!.length; i++) {
        await roomRef
            .collection('Devices')
            .doc(room.devices![i].deviceId)
            .set(room.devices![i].toMap());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> editRoom(RoomModel room) async {
    try {
      // Reference to the room document
      final roomRef = _firestore
          .collection(roomsCollection)
          .doc('Room No. ${room.roomNumber}');

      // Update only the specified fields (groupValue, roomNumber, Name)
      await roomRef.update({
        'Name': room.roomName,
        'roomNumber': room.roomNumber,
        'groupValue': room.groupCurrentStatus,
      });
    } catch (e) {
      log('Error updating room: ${e.toString()}');
    }
  }

  deleteRoom(String roomNo) async {
    try {
      await _firestore
          .collection(roomsCollection)
          .doc('Room No. $roomNo')
          .delete();
      log('Room No. $roomNo deleted successfully');
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<List<RoomModel>> fetchAllRooms() async {
    final rooms = await _firestore.collection(roomsCollection).get();
    return rooms.docs.map((e) {
      return RoomModel.fromMap(e.data());
    }).toList();
  }

  Future<List<DeviceModel>> fetchDevices(String roomNo) async {
    final devices = await _firestore
        .collection(roomsCollection)
        .doc('Room No. $roomNo')
        .collection('Devices')
        .get();
    return devices.docs.map((e) {
      return DeviceModel.fromMap(e.data());
    }).toList();
  }

  updateDeviceStatus(String roomNo, String deviceId, String status) async {
    log('Updating $deviceId status to : $status');
    return _firestore
        .collection(roomsCollection)
        .doc('Room No. $roomNo')
        .collection('Devices')
        .doc(deviceId)
        .update({
      'status': status,
    });
  }

  updateGroupStatus(String roomNumber, bool status) async {
    return await _firestore
        .collection(roomsCollection)
        .doc('Room No. $roomNumber')
        .update({
      'groupValue': status,
    });
  }

  addNotification(NotificationModel notification) async {
    await _firestore
        .collection('Notifications')
        .doc(notification.notificationId)
        .set(notification.toMap());
  }

  deleteNotification(String notificationId) {
    _firestore.collection('Notifications').doc(notificationId).delete();
  }

  Stream<List<NotificationModel>> getNotifications() {
    return _firestore.collection('Notifications').snapshots().map(
      (event) {
        List<NotificationModel> notifications = [];

        for (var notificationDoc in event.docs) {
          final notification =
              NotificationModel.fromMap(notificationDoc.data());
          notifications.add(notification);
        }

        return notifications;
      },
    );
  }
}
