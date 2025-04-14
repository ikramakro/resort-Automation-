import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';
import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/config/route_navigation.dart';
import 'package:resort_web_app/services/mqtt_service.dart';
import 'package:resort_web_app/theme/theme.dart';
import 'package:resort_web_app/theme/theme_controller.dart';

import 'config/service_locator.dart';
import 'features/home_screen/view/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDAXdLK2NIQaJ-mhoqI44Y3UCX7NZU1GnU',
      appId: '1:456492763184:web:30867fdadf8df6bde1c5f5',
      messagingSenderId: '456492763184',
      projectId: 'resort-automation-app-backend',
      authDomain: 'resort-automation-app-backend.firebaseapp.com',
      storageBucket: 'resort-automation-app-backend.firebasestorage.app',
    ),
  );
  //.........SET UP LOCATOR
  await setupLocator();

  runApp(
    ProviderScope(
      child: const ResortApp(),
    ),
  );
}

class ResortApp extends ConsumerStatefulWidget {
  const ResortApp({super.key});

  @override
  ConsumerState<ResortApp> createState() => _ResortAppState();
}

class _ResortAppState extends ConsumerState<ResortApp> {
  final _mqttService = MqttService();
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        _mqttService.connect();
      },
    );

    Connectivity().onConnectivityChanged.listen(
      (result) {
        if (result[0] != ConnectivityResult.none && !_mqttService.isConnected) {
          log('Internet connection restored. Attempting to reconnect...');
          MqttService().connect();
        } else if (result == ConnectivityResult.values) {
          log('No internet connection');
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(themeProvider.notifier).setInitialTheme();
    });
    return Builder(builder: (context) {
      final themeMode = ref.watch(themeProvider);
      return MaterialApp(
        darkTheme: darkTheme,
        themeMode: themeMode,
        theme: lightTheme,
        onGenerateRoute: onGenRoute,
        initialRoute: '/',
        home: HomeScreen(),
      );
    });
  }
}
