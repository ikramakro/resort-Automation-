import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/features/home_screen/controller/controller.dart';
import 'package:resort_web_app/features/notifications_page/view/notifications_page.dart';
import 'package:resort_web_app/features/room_page/controller/room_page_controller.dart';
import 'package:resort_web_app/features/room_page/view/room_page.dart';
import 'package:resort_web_app/models/notification_model.dart';
import 'package:resort_web_app/models/room_model.dart';

import '../../../../theme/theme_controller.dart';

class LogoAndTitle extends StatelessWidget {
  const LogoAndTitle(
      {super.key, required this.controller, required this.themeController});
  static const logo = 'assets/images/khar_logo_dark.png';
  final MainScreenController controller;
  final ThemeController themeController;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Image.asset(
              logo,
              width: 150,
              height: 150,
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: Align(
            alignment: Alignment(0.4, 0.0),
            child: Text(
              AppStringConstants.dashboardScreenTitle,
              style: GoogleFonts.montserrat(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ),
        ),
        Expanded(
            child: Center(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Center(
                  child: SizedBox(
                    width: 500,
                    height: 350,
                    child: AlertDialog(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkGreyColor
                              : AppColors.greyColor,
                      title: Center(child: Text('Add Room Number')),
                      content: Center(
                        child: SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: controller.roomNumberController,
                          ),
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (controller
                                        .roomNumberController.text.isNotEmpty) {
                                      controller.addRoom(context);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text('Add',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Icon(
              Icons.add,
              size: 40,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        )),
        Expanded(
            child: Center(
          child: GestureDetector(
            onTap: () {
              themeController.toggleTheme();
            },
            child: Icon(
              Icons.light_mode_outlined,
              size: 40,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        )),
        Expanded(
            child: Center(
          child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, NotificationsPage.pageName),
              child: Consumer(
                builder: (context, ref, child) {
                  ref.watch(mainScreenControllerProvider);
                  return Stack(children: [
                    Icon(
                      Icons.notifications,
                      size: 40,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.redColor,
                        child: Center(
                          child: StreamBuilder<List<NotificationModel>>(
                            stream: controller.getNotificationsCount(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox();
                              } else if (snapshot.connectionState ==
                                      ConnectionState.done ||
                                  snapshot.connectionState ==
                                      ConnectionState.active) {
                                return Center(
                                  child: Text(
                                    snapshot.data!.length.toString(),
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        color: AppColors.whiteColor),
                                  ),
                                );
                              } else {
                                return Text(
                                  '0',
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteColor),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ]);
                },
              )),
        )),
      ],
    );
  }
}

class RoomsList extends StatelessWidget {
  const RoomsList({super.key, required this.rooms});
  final List<RoomModel> rooms;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 30.0),
          child: RoomTile(room: rooms[index]),
        );
      },
    );
  }
}

class RoomTile extends ConsumerWidget {
  const RoomTile({super.key, required this.room});
  final RoomModel room;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref
            .read(roomPageControllerProvider.notifier)
            .reinitialzeState(room.groupCurrentStatus);
        Navigator.pushNamed(context, RoomPage.pageName, arguments: {
          'room': room.roomName.toString(),
          'groupValue': room.groupCurrentStatus
        });
      },
      // onDoubleTap: () => ref
      //     .read(mainScreenControllerProvider.notifier)
      //     .deleteRoom(room.roomNumber),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkGreyColor
            : AppColors.greyColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
          leading: Icon(
            Icons.room_preferences,
            size: 40, // Adjust icon size as needed
            color: AppColors.blackColor,
          ),
          title: Text(
            '${room.roomName}',
            style: GoogleFonts.montserrat(
              fontSize: 24, // Adjust font size as needed
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_outlined,
              size: 40, // Adjust icon size as needed
              color: AppColors.blackColor,
            ),
            onSelected: (value) {
              // Handle the selected menu item
              print('Selected: $value for Room No.${room.roomNumber}');
              switch (value) {
                case 'details':
                  ref
                      .read(roomPageControllerProvider.notifier)
                      .reinitialzeState(room.groupCurrentStatus);
                  Navigator.pushNamed(context, RoomPage.pageName, arguments: {
                    'room': room.roomNumber,
                    'groupValue': room.groupCurrentStatus
                  });
                  break;
                case 'edit':
                  // Navigate to edit room screen
                  break;
                case 'delete':
                  ref
                      .read(mainScreenControllerProvider.notifier)
                      .deleteRoom(room.roomNumber);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'details',
                child: Text('Details'),
              ),
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
