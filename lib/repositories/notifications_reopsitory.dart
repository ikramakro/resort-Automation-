import 'package:resort_web_app/models/notification_model.dart';
import 'package:resort_web_app/services/firebase_service.dart';

import '../config/service_locator.dart';

class NotificationsRepository {
  static NotificationsRepository? _instance;

  NotificationsRepository._init();

  factory NotificationsRepository() {
    return _instance ??= NotificationsRepository._init();
  }

  final FirebaseService _firebaseService =
      serviceLocator.get<FirebaseService>();
  Stream<List<NotificationModel>> getAllNotifications() {
    return _firebaseService.getNotifications();
  }

  removeNotification(String notificationId) async {
    await _firebaseService.deleteNotification(notificationId);
  }

  addNotification(NotificationModel notification) async {
    await _firebaseService.addNotification(notification);
  }
}
