import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/config/service_locator.dart';
import 'package:resort_web_app/core/utils/shared_pref_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends Notifier<ThemeMode> {
  @override
  build() {
    return ThemeMode.dark;
  }

  toggleTheme() async {
    final sharedPref = serviceLocator.get<SharedPreferences>();
    final isDarkMode =
        sharedPref.getBool(SharedPrefConstants.isDarkMode) ?? true;
    await sharedPref.setBool(SharedPrefConstants.isDarkMode, !isDarkMode);
    state = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  setInitialTheme() {
    final sharedPref = serviceLocator.get<SharedPreferences>();
    final isDarkMode =
        sharedPref.getBool(SharedPrefConstants.isDarkMode) ?? true;
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
