import 'dart:developer';

import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/config/service_locator.dart';
import 'package:resort_web_app/models/device_model.dart';
import 'package:resort_web_app/models/room_model.dart';
import 'package:resort_web_app/repositories/rooms_repostitory.dart';
import 'package:resort_web_app/services/mqtt_service.dart';

import '../../../repositories/notifications_reopsitory.dart';

final mainScreenControllerProvider =
    NotifierProvider<MainScreenController, MainScreenStates>(
        MainScreenController.new);

class MainScreenController extends Notifier<MainScreenStates> {
  List<RoomModel> roomsList = [];
  int notificationsCount = 0;
  //...........SERVCIES
  final roomRepo = serviceLocator.get<RoomRepository>();
  final notificationsRepo = serviceLocator.get<NotificationsRepository>();
  final mqttService = MqttService();

  //..............CONTROLLERS
  final TextEditingController roomNumberController = TextEditingController();
  final TextEditingController roomNameController = TextEditingController();
  @override
  MainScreenStates build() {
    ref.onDispose(
      () => roomNumberController.dispose(),
    );
    return MainScreenLoadingState();
  }

  getNotificationsCount() {
    return notificationsRepo.getAllNotifications();
  }

  void fetchAllRooms() async {
    try {
      state = MainScreenLoadingState();
      roomsList = await roomRepo.fetchAllRooms();
      state = MainScreenDataFetchedState(
        roomsList: roomsList,
      );
    } catch (e) {
      log(e.toString());
      state = MainScreenErrorState(
        message: e.toString(),
      );
    }
  }

  void addRoom(BuildContext context) async {
    try {
      state = MainScreenLoadingState();
      final roomNumber = roomNumberController.text.trim();
      final roomName = roomNameController.text.trim();
      //...........CREATE TOPICS
      final topic = 'roomNo/$roomNumber/init';
      // if (mqttService.isConnected) {
      //.........PUBLISH TOPIC WITH ROOM NUMBER

      //................ADD ROOM TO FRIESTORE
      await roomRepo.addRoom(RoomModel(
          roomNumber: roomNumber,
          roomName: roomName,
          groupCurrentStatus: false,
          devices: [
            for (int i = 1; i <= 4; i++)
              DeviceModel(
                deviceId: 'Room $roomNumber Light $i',
                status: "0x0200",
                attributes: {
                  'Brigtness': '0x0210',
                },
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
          ]));
      mqttService.publishMessage(
          topic: topic, message: {'roomNo': roomNumber}.toString());
      // context.showPopUpMessage('Room Added Successfull');
      roomNumberController.clear();
      roomNameController.clear();
      state = MainScreenLoadedState();
      // } else {
      //   log('mqtt not connected cannot add room');
      //   state = MainScreenErrorState(
      //     message: 'Mqtt not connected cannot add room',
      //   );
      // }
    } catch (e) {
      state = MainScreenErrorState(
        message: e.toString(),
      );
    }
  }

  Future<void> editRoom(BuildContext context, String roomName,
      String roomNumber, bool groupCurrentStatus) async {
    try {
      state = MainScreenLoadingState();

      // If roomNameController or roomNumberController is empty or null, fallback to the passed parameters
      final newRoomName = roomNameController.text.trim().isEmpty
          ? roomName
          : roomNameController.text.trim();
      final newRoomNumber = roomNumberController.text.trim().isEmpty
          ? roomNumber
          : roomNumberController.text.trim();
      final newGroupValue =
          groupCurrentStatus; // Assuming you may want to directly use the passed value

      if (newRoomName != roomName || newGroupValue != groupCurrentStatus) {
        // Update the room details in Firestore
        await roomRepo.editRoom(RoomModel(
          roomNumber: newRoomNumber,
          roomName: newRoomName,
          groupCurrentStatus: newGroupValue,
        ));

        // Update MQTT topic if needed
        final topic = 'roomNo/$newRoomNumber/init';
        if (mqttService.isConnected) {
          // Publish updated room information
          mqttService.publishMessage(
              topic: topic, message: {'roomNo': newRoomNumber}.toString());
        } else {
          log('MQTT not connected, cannot update room');
        }

        // Re-fetch the rooms list to reflect changes
        // await fetchAllRooms();

        // Clear the controllers after successful operation
        roomNameController.clear();
        roomNumberController.clear();
        state = MainScreenLoadedState();
        // context.showPopUpMessage('Room Updated Successfully');
      } else {
        state = MainScreenLoadedState();
        // context.showPopUpMessage('No changes detected');
      }
    } catch (e) {
      log(e.toString());
      state = MainScreenErrorState(
        message: e.toString(),
      );
    }
  }

// Future<void> editRoom(BuildContext context, String oldRoomNumber) async {
//     try {
//       state = MainScreenLoadingState();
//       final newRoomNumber = editRoomNumberController.text.trim();

//       if (newRoomNumber != oldRoomNumber) {
//         // Update the room number in Firestore
//         await roomRepo.updateRoomNumber(oldRoomNumber, newRoomNumber);

//         // Update MQTT topics if needed (consider implications)
//         // You might need to unsubscribe from the old topic and subscribe to the new one.
//         // This depends on how your MQTT topics are structured and used.
//         final oldTopic = 'roomNo/$oldRoomNumber/init';
//         final newTopic = 'roomNo/$newRoomNumber/init';
//         log('Old Topic: $oldTopic, New Topic: $newTopic');
//         // Implement MQTT topic update logic if necessary
//       }

//       // Re-fetch the rooms list to reflect the changes
//       await fetchAllRooms();
//       // context.showPopUpMessage('Room Updated Successfully');
//       editRoomNumberController.clear();
//       state = MainScreenLoadedState();
//     } catch (e) {
//       log(e.toString());
//       state = MainScreenErrorState(
//         message: e.toString(),
//       );
//     }
//   }

  deleteRoom(String roomNumber) async {
    try {
      state = MainScreenLoadingState();
      await roomRepo.deleteRoom(roomNumber);
      state = MainScreenLoadedState();
    } catch (e) {
      log(e.toString());
      state = MainScreenErrorState(
        message: e.toString(),
      );
    }
  }
}

//.................STATES.......................
sealed class MainScreenStates {
  const MainScreenStates();
}

final class MainScreenInitialState extends MainScreenStates {}

final class MainScreenLoadingState extends MainScreenStates {}

final class MainScreenDataFetchedState extends MainScreenStates {
  final List<RoomModel> roomsList;
  const MainScreenDataFetchedState({required this.roomsList});
}

final class MainScreenLoadedState extends MainScreenStates {}

final class MainScreenErrorState extends MainScreenStates {
  final String message;
  const MainScreenErrorState({required this.message});
}
