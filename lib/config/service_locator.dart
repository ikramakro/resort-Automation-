import 'package:get_it/get_it.dart';
import 'package:resort_web_app/repositories/devices_repository.dart';
import 'package:resort_web_app/repositories/notifications_reopsitory.dart';
import 'package:resort_web_app/repositories/rooms_repostitory.dart';
import 'package:resort_web_app/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt serviceLocator = GetIt.instance;

setupLocator() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(
    () => sharedPreferences,
  );
  serviceLocator.registerSingleton<FirebaseService>(FirebaseService());
  serviceLocator.registerSingleton<RoomRepository>(RoomRepository());
  serviceLocator.registerSingleton<DevicesRepository>(DevicesRepository());
  serviceLocator
      .registerSingleton<NotificationsRepository>(NotificationsRepository());
}
