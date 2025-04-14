import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/features/notifications_page/controller/notifications_controller.dart';
import 'package:resort_web_app/models/notification_model.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key, required this.notifications});
  final List<NotificationModel> notifications;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: NotificationTile(
            notification: notifications[index],
          ),
        );
      },
    );
  }
}

class NotificationTile extends ConsumerWidget {
  const NotificationTile({super.key, required this.notification});
  final NotificationModel notification;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        width: ScreenSize.getWidth(context) * 0.8,
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkGreyColor
              : AppColors.greyColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            children: [
              Expanded(
                  child: Center(
                child: Icon(
                  getServiceIcon(notification.serviceType),
                  size: 50,
                  color: AppColors.blackColor,
                ),
              )),
              Expanded(
                flex: 8,
                child: Text(
                  'Room No.${notification.roomNumber} has requested ${notification.serviceType} Service',
                  style: GoogleFonts.montserrat(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => ref
                      .read(notificationsProvider.notifier)
                      .deleteNotification(notification.notificationId),
                  child: Icon(
                    Icons.clear,
                    size: 50,
                    color: AppColors.blackColor,
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  getServiceIcon(String serviceType) => switch (serviceType) {
        'Laundry' => Icons.local_laundry_service_outlined,
        'Cleaning' => Icons.cleaning_services_outlined,
        _ => Icons.do_not_disturb_off_outlined,
      };
}
