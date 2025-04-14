import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/features/home_screen/view/home_screen.dart';
import 'package:resort_web_app/features/notifications_page/view/notifications_page.dart';
import 'package:resort_web_app/features/room_page/view/room_page.dart';

Route<dynamic> onGenRoute(RouteSettings settings) {
  return switch (settings.name) {
    '/' => MaterialPageRoute(builder: (context) => HomeScreen()),
    '/roomPage' =>
      MaterialPageRoute(builder: (context) => RoomPage(), settings: settings),
    NotificationsPage.pageName =>
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    _ => MaterialPageRoute(builder: (context) => HomeScreen()),
  };
}
