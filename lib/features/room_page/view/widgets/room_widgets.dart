import 'dart:developer';

import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/core/common/functions/common_functions.dart';
import 'package:resort_web_app/features/room_page/controller/room_page_controller.dart';
import 'package:resort_web_app/models/device_model.dart';

class Lights extends ConsumerWidget {
  const Lights(
      {super.key,
      required this.isDataFetched,
      required this.groupValue,
      required this.roomNumber,
      this.lightOne,
      this.lightTwo,
      this.lightThree,
      this.lightFour});
  final bool isDataFetched, groupValue;
  final String roomNumber;
  final DeviceModel? lightOne, lightTwo, lightThree, lightFour;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: LightsRow(
            firstLight: isDataFetched ? lightOne : null,
            secondLight: isDataFetched ? lightTwo : null,
            roomNumber: roomNumber,
          ),
        ),
        Expanded(
          flex: 3,
          child: LightsRow(
            firstLight: isDataFetched ? lightThree : null,
            secondLight: isDataFetched ? lightFour : null,
            roomNumber: roomNumber,
          ),
        ),
        Expanded(
          child: LightsGroupSwitch(
            groupValue: groupValue,
            roomNumber: roomNumber,
          ),
        )
      ],
    );
  }
}

class LightsRow extends StatelessWidget {
  const LightsRow(
      {super.key, this.firstLight, this.secondLight, required this.roomNumber});
  final DeviceModel? firstLight, secondLight;
  final String roomNumber;
  @override
  Widget build(BuildContext context) {
    final isDataFetched = firstLight != null && secondLight != null;
    return Row(
      children: [
        Expanded(
            child: isDataFetched
                ? Light(
                    light: firstLight!,
                    roomNumber: roomNumber,
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )),
        Expanded(
            child: isDataFetched
                ? Light(
                    light: secondLight!,
                    roomNumber: roomNumber,
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )),
      ],
    );
  }
}

class Light extends ConsumerWidget {
  const Light({super.key, required this.light, required this.roomNumber});
  final DeviceModel light;
  final String roomNumber;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    log('light status ${light.status}');
    var switchValue = light.status == '0x0201';
    final controller = ref.read(roomPageControllerProvider.notifier);
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 150,
              height: 200,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.blackColor : AppColors.whiteColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
                  width: 11,
                ),
              ),
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return Switch(
                activeColor: AppColors.whiteColor,
                activeTrackColor: AppColors.greenColor,
                value: switchValue,
                onChanged: (value) {
                  setState(() {
                    switchValue = value;
                  });
                  controller.updateDeviceStatus(roomNumber, light, value);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class LightsGroupSwitch extends ConsumerWidget {
  const LightsGroupSwitch(
      {super.key, required this.groupValue, required this.roomNumber});
  final bool groupValue;
  final String roomNumber;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var switchValue = groupValue;
    final controller = ref.read(roomPageControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          AppBackButton(
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Align(
              alignment: Alignment(0.9, 0.0),
              child: Text(
                AppStringConstants.roomScreenGroupText,
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
              child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Switch.adaptive(
                  activeColor: AppColors.whiteColor,
                  activeTrackColor: AppColors.greenColor,
                  value: switchValue,
                  onChanged: (value) async {
                    setState(
                      () {
                        switchValue = value;
                      },
                    );
                    showProgressDialog(
                        context: context,
                        message: 'Updating All devices in group');
                    await controller.onGroupStatusChange(
                        value: value, roomNumber: roomNumber);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          )),
        ],
      ),
    );
  }
}
