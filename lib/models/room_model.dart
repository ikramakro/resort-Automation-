// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:resort_web_app/models/device_model.dart';

class RoomModel {
  final String roomNumber;
  final String? roomName;
  final List<DeviceModel>? devices;
  final bool groupCurrentStatus;
  const RoomModel(
      {required this.roomNumber,
      this.roomName,
      this.devices,
      required this.groupCurrentStatus});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'roomNumber': roomNumber,
      'Name': roomName,
      'devices': devices!.map((x) => x.toMap()).toList(),
      'groupValue': groupCurrentStatus,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      roomNumber: map['roomNumber'] ?? '',
      roomName: map['Name'] ?? '',
      devices: map['devices'] != null
          ? List<DeviceModel>.from(
              (map['devices'] as List<Map<String, dynamic>>).map<DeviceModel?>(
                (x) => DeviceModel.fromMap(x),
              ),
            )
          : null,
      groupCurrentStatus: map['groupValue'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
