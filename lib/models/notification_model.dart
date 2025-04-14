class NotificationModel {
  final String notificationId;
  final String roomNumber;
  final String serviceType;
  const NotificationModel({
    required this.notificationId,
    required this.roomNumber,
    required this.serviceType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'notificationId': notificationId,
      'roomNumber': roomNumber,
      'serviceType': serviceType,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      serviceType: map['serviceType'] ?? '',
    );
  }
}
