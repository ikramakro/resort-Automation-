import 'package:flutter/scheduler.dart';
import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/core/common/widgets/loading_widget.dart';
import 'package:resort_web_app/features/room_page/controller/room_page_controller.dart';
import 'package:resort_web_app/features/room_page/view/widgets/room_widgets.dart';

class RoomPage extends ConsumerWidget {
  const RoomPage({super.key});
  static const pageName = '/roomPage';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomMap =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final controller = ref.read(roomPageControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'ROOM NO. ${roomMap['room']} LIGHTS',
            style: GoogleFonts.montserrat(
              color: Theme.of(context).textTheme.bodyMedium!.color,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final state = ref.watch(roomPageControllerProvider);
          switch (state) {
            case RoomPageInitialState():
              return Lights(
                isDataFetched: true,
                lightOne: controller.devices[0],
                lightTwo: controller.devices[1],
                lightThree: controller.devices[2],
                lightFour: controller.devices[3],
                groupValue: controller.groupStatus,
                roomNumber: roomMap['room'].toString(),
              );
            case RoomPageLoadingState():
              return LoadingWidget(
                event: () => ref
                    .read(roomPageControllerProvider.notifier)
                    .fetchRoomLights(
                        roomMap['room'].toString(), controller.groupStatus),
                child: Lights(
                  isDataFetched: false,
                  groupValue: controller.groupStatus,
                  roomNumber: roomMap['room'].toString(),
                ),
              );
            case RoomPageDataFetchedState():
              return Lights(
                isDataFetched: true,
                lightOne: state.devices[0],
                lightTwo: state.devices[1],
                lightThree: state.devices[2],
                lightFour: state.devices[3],
                groupValue: state.groupStatus,
                roomNumber: roomMap['room'].toString(),
              );
            case RoomPageSuccessState():
              return Lights(
                isDataFetched: true,
                lightOne: controller.devices[0],
                lightTwo: controller.devices[1],
                lightThree: controller.devices[2],
                lightFour: controller.devices[3],
                groupValue: controller.groupStatus,
                roomNumber: roomMap['room'].toString(),
              );
            case RoomPageErrorState():
              SchedulerBinding.instance.addPostFrameCallback(
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage)));
                },
              );
              return Center(
                  child: Text(
                'Please check your intenet connection and try again!',
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontSize: 30.0,
                ),
              ));
          }
        },
      ),
    );
  }
}
