import 'dart:developer';

import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/config/service_locator.dart';
import 'package:resort_web_app/models/device_model.dart';
import 'package:resort_web_app/repositories/rooms_repostitory.dart';

import '../../../core/common/functions/common_functions.dart';
import '../../../repositories/devices_repository.dart';
import '../../../services/mqtt_service.dart';

final roomPageControllerProvider =
    NotifierProvider<RoomPageController, RoomPageStates>(
        RoomPageController.new);

class RoomPageController extends Notifier<RoomPageStates> {
  List<DeviceModel> devices = [];
  var groupStatus = false;

  //...............SERVICES
  final _devicesRepo = serviceLocator.get<DevicesRepository>();
  final _mqttService = MqttService();
  final _roomRepo = serviceLocator.get<RoomRepository>();
  @override
  build() {
    return RoomPageLoadingState();
  }

  fetchRoomLights(String roomNo, bool groupValue) async {
    try {
      if (_mqttService.isConnected) {
        groupStatus = groupValue;
        state = RoomPageLoadingState();
        devices = await _devicesRepo.fetchRoomDevices(roomNo);
        if (devices.isEmpty) {
          state = RoomPageErrorState();
        } else {
          state = RoomPageDataFetchedState(
            devices: devices,
            groupStatus: groupValue,
          );
        }
      } else {
        state = RoomPageErrorState(errorMessage: 'Please Connect to Internet');
      }
    } catch (e) {
      log(e.toString());
      state = RoomPageErrorState();
    }
  }

  updateDeviceStatus(String roomNumber, DeviceModel device, bool value) async {
    try {
      if (_mqttService.isConnected) {
        state = RoomPageLoadingState();
        final command = value ? "0x0201" : "0x0200";

        _mqttService.publishDeviceUpdate(
          roomNumber,
          device.deviceId,
          command,
          device.attributes[device.attributes.keys.first],
          _mqttService,
        );

        await _devicesRepo.updateDeviceStatus(
            roomNumber, device.deviceId, command);
        state = RoomPageSuccessState();
      } else {
        state = RoomPageErrorState(
          errorMessage: 'Please Connect to Internet and try again',
        );
      }
    } catch (e) {
      log('error updating light status ${e.toString()}');
      state = RoomPageErrorState();
    }
  }

  onGroupStatusChange({required bool value, required String roomNumber}) async {
    try {
      if (_mqttService.isConnected) {
        for (var device in devices) {
          final command = value ? "0x0201" : "0x0200";

          //.............PUBLISH CHANGE IN DEVICES VALUE
          _mqttService.publishDeviceUpdate(
            roomNumber,
            device.deviceId,
            command,
            device.attributes[device.attributes.keys.first],
            _mqttService,
          );

          log('device update published with status : $command');

          //...........UPDATE DEVICE VALUES IN FIRESTORE
          bool currentDevicestatus =
              hexaIntoStringForBulb(device.status) == "On" ? true : false;

          if (currentDevicestatus != value) {
            log('current status and new status are different');
            await _devicesRepo.updateDeviceStatus(
                roomNumber, device.deviceId, command);
          } else {
            log('current status and new status are same');
          }
        }

        //........UPDATE ROOM GROUP VALUE IN FIRESTORE
        await _roomRepo.updateGroupStatus(
          roomNumber,
          value,
        );

        fetchRoomLights(
          roomNumber,
          value,
        );
      } else {
        state = RoomPageErrorState(
          errorMessage: 'Please Connect to Internet and try again',
        );
      }
    } catch (e) {
      log('error updating the group status ${e.toString()}');
      state = RoomPageErrorState();
    }
  }

  reinitialzeState(bool groupStatus) {
    devices = [];
    groupStatus = false;
    state = RoomPageLoadingState();
  }
}

sealed class RoomPageStates {
  const RoomPageStates();
}

final class RoomPageInitialState extends RoomPageStates {}

final class RoomPageLoadingState extends RoomPageStates {}

final class RoomPageDataFetchedState extends RoomPageStates {
  final List<DeviceModel> devices;
  final bool groupStatus;
  const RoomPageDataFetchedState(
      {required this.devices, required this.groupStatus});
}

final class RoomPageErrorState extends RoomPageStates {
  final String errorMessage;

  const RoomPageErrorState({this.errorMessage = 'Something went wrong'});
}

final class RoomPageSuccessState extends RoomPageStates {}
