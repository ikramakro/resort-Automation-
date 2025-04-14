import '../../../barrel.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.whiteColor
              : AppColors.blackColor,
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.blackColor
                : AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key, required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.whiteColor
                : AppColors.blackColor,
            width: 5.0,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppColors.blackColor,
            size: 60,
          ),
        ),
      ),
    );
  }
}

class ConfirmCancelButtonsRow extends StatelessWidget {
  const ConfirmCancelButtonsRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: AppBackButton(),
        ),
        Expanded(
          flex: 8,
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 300.0),
                    child: ConfirmCancelButton(
                      btnText:
                          AppStringConstants.timeSettingScreenChangebtnText,
                    ),
                  )),
              Expanded(
                  child: ConfirmCancelButton(
                btnText: AppStringConstants.timeSettingScreenCancelbtnText,
              )),
            ],
          ),
        ),
        Spacer(),
      ],
    );
  }
}

class ConfirmCancelButton extends StatelessWidget {
  const ConfirmCancelButton({super.key, required this.btnText});
  final String btnText;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.blackColor,
            border: Border.all(
              color: AppColors.whiteColor,
              width: 2,
            )),
        child: Center(
          child: Text(
            btnText,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
