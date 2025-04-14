import 'package:resort_web_app/barrel.dart';
import 'package:resort_web_app/core/common/widgets/loading_widget.dart';
import 'package:resort_web_app/features/home_screen/view/widgets/home_screen_widgets.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../theme/theme_controller.dart';
import '../controller/controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late SidebarXController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SidebarXController(selectedIndex: 0, extended: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Rooms';
      case 2:
        return 'Dining';
      case 3:
        return 'Spa & Wellness';
      case 4:
        return 'Events';
      case 5:
        return 'Settings';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainScreenController =
        ref.read(mainScreenControllerProvider.notifier);
    final themeController = ref.read(themeProvider.notifier);

    return Scaffold(
      body: Row(
        children: [
          SidebarX(
            controller: _controller,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              selectedTextStyle: const TextStyle(color: Colors.white),
              itemTextPadding: const EdgeInsets.only(left: 30),
              selectedItemTextPadding: const EdgeInsets.only(left: 30),
              itemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).cardColor),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, Colors.indigo.shade200],
                ),
              ),
              iconTheme: IconThemeData(
                color: Theme.of(context).iconTheme.color,
                size: 20,
              ),
            ),
            extendedTheme: SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkGreyColor
                    : AppColors.greyColor,
              ),
            ),
            footerDivider: Divider(color: Colors.grey.shade300, height: 1),
            // headerBuilder: (context, extended) {
            //   return SizedBox(
            //     height: 100,
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: LogoAndTitle(
            //         controller: mainScreenController,
            //         themeController: themeController,
            //       ),
            //     ),
            //   );
            // },
            headerBuilder: (context, extended) {
              const logo = 'assets/images/khar_logo_dark.png';
              return SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Image.asset(
                      logo,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              );
            },

            items: [
              SidebarXItem(
                icon: Icons.home,
                label: 'Home',
              ),
              SidebarXItem(
                icon: Icons.hotel,
                label: 'Rooms',
              ),
              SidebarXItem(
                icon: Icons.restaurant,
                label: 'Dining',
              ),
              SidebarXItem(
                icon: Icons.spa,
                label: 'Spa & Wellness',
              ),
              SidebarXItem(
                icon: Icons.event,
                label: 'Events',
              ),
              SidebarXItem(
                icon: Icons.settings,
                label: 'Settings',
              ),
            ],
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final pageTitle = _getTitleByIndex(_controller.selectedIndex);
                switch (_controller.selectedIndex) {
                  case 0:
                    return _buildHomeScreenContent(
                        context, ref, mainScreenController);
                  default:
                    return Center(
                      child: Text(
                        pageTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreenContent(BuildContext context, WidgetRef ref,
      MainScreenController mainScreenController) {
    final state = ref.watch(mainScreenControllerProvider);
    final themeController = ref.read(themeProvider.notifier);
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: LogoAndTitle(
            controller: mainScreenController,
            themeController: themeController,
          ), // Logo and title are in the sidebar now
        ),
        Expanded(
          flex: 8,
          child: Builder(
            builder: (context) {
              switch (state) {
                case MainScreenInitialState():
                  return Center(
                    child: RoomsList(rooms: mainScreenController.roomsList),
                  );
                case MainScreenLoadingState():
                  return LoadingWidget(
                    event: mainScreenController.fetchAllRooms,
                    child: RoomsList(
                      rooms: mainScreenController.roomsList,
                    ),
                  );
                case MainScreenDataFetchedState():
                  return Center(child: RoomsList(rooms: state.roomsList));
                case MainScreenLoadedState():
                  return Center(
                      child: RoomsList(rooms: mainScreenController.roomsList));
                case MainScreenErrorState():
                  return Center(child: Text(state.message));
              }
            },
          ),
        ),
      ],
    );
  }
}
