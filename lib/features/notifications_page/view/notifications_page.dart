import 'dart:developer';

import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/core/common/widgets/loading_widget.dart';
import 'package:resort_web_app/features/notifications_page/controller/notifications_controller.dart';
import 'package:resort_web_app/features/notifications_page/view/widgets/notifications_page_widgets.dart';
import 'package:resort_web_app/models/notification_model.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});
  static const pageName = '/notifications';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsController = ref.read(notificationsProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
            size: 30,
          ),
        ),
        title: Center(
          child: Text(
            AppStringConstants.notificationScreenTitle,
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        ),
      ),
      body: Center(
        child: StreamBuilder<List<NotificationModel>>(
          stream: notificationsController.getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingWidget(
                  child: NotificationsList(
                      notifications: notificationsController.notifications));
            } else if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.active) {
              var notifications = <NotificationModel>[];
              if (snapshot.data != null) {
                notifications = snapshot.data!;
                notificationsController.notifications = notifications;
              } else {
                log('snapshot data is null');
              }
              return Center(
                child: NotificationsList(notifications: notifications),
              );
            } else {
              return NotificationsList(
                  notifications: notificationsController.notifications);
            }
          },
        ),
      ),
    );
  }
}
