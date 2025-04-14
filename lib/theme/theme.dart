import '../barrel.dart';

ThemeData lightTheme = ThemeData(
  listTileTheme: ListTileThemeData(iconColor: AppColors.greyColor),
  appBarTheme: AppBarTheme(color: AppColors.whiteColor),
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.whiteColor,
  iconTheme: IconThemeData(color: AppColors.blackColor),
);

ThemeData darkTheme = ThemeData(
  listTileTheme: ListTileThemeData(iconColor: AppColors.darkGreyColor),
  appBarTheme: AppBarTheme(color: AppColors.blackColor),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.blackColor,
  iconTheme: IconThemeData(color: AppColors.whiteColor),
);
