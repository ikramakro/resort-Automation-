import '../../../barrel.dart';

hexaIntoStringForBulb(String hexa) => switch (hexa) {
      "0x0201" => "On",
      "0x0200" => "Off",
      _ => "Off",
    };

extension PopUpMessages on BuildContext {
  showPopUpMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}

void showProgressDialog({
  required BuildContext context,
  required String message,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissal by tapping outside
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final isDarkMode = theme.brightness == Brightness.dark;

      return AlertDialog(
        backgroundColor:
            isDarkMode ? AppColors.darkGreyColor : AppColors.greyColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}
