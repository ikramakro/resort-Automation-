// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DeviceModel {
  final String deviceId;
  final String status;
  final Map<String, dynamic> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeviceModel({
    required this.deviceId,
    required this.status,
    required this.attributes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deviceId': deviceId,
      'status': status,
      'attributes': attributes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      deviceId: map['deviceId'] as String,
      status: map['status'] as String,
      attributes: map['attributes'] as Map<String, dynamic>,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceModel.fromJson(String source) =>
      DeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
