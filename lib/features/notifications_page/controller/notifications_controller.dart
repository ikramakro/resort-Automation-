import 'dart:developer';

import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/repositories/notifications_reopsitory.dart';

import '../../../models/notification_model.dart';

final notificationsProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
        NotificationsController.new);

class NotificationsController extends Notifier<NotificationsState> {
  final NotificationsRepository _notificationsRepo = NotificationsRepository();
  List<NotificationModel> notifications = [];

  @override
  build() {
    return NotificationsInitial();
  }

  getNotifications() {
    return _notificationsRepo.getAllNotifications();
  }

  deleteNotification(String notificationId) async {
    try {
      state = NotificationsLoading();
      await _notificationsRepo.removeNotification(notificationId);
    } catch (e) {
      log('error fetching notifications : ${e.toString()}');
      state = NotificationsError(error: e.toString());
    }
  }
}

sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {}

final class NotificationsError extends NotificationsState {
  final String error;
  const NotificationsError({required this.error});
}
