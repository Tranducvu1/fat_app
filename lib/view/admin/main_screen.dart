import 'package:fat_app/view/admin/side_bar_screens/courses_screen.dart';
import 'package:fat_app/view/admin/side_bar_screens/dashboard_screen.dart';
import 'package:fat_app/view/admin/side_bar_screens/ranking.dart';
import 'package:fat_app/view/admin/side_bar_screens/statistical.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _selecttedItem = DashboardScreen();

  screenSelector(item) {
    switch (item.route) {
      case DashboardScreen.routeName:
        setState(() {
          _selecttedItem = DashboardScreen();
        });

        break;
      case CourseScreen.routeName:
        setState(() {
          _selecttedItem = CourseScreen();
        });
        break;

      case rankingScreen.routeName:
        setState(() {
          _selecttedItem = rankingScreen();
        });
        break;

      case WithdrawalScreen.routeName:
        setState(() {
          _selecttedItem = WithdrawalScreen();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade900,
          title: const Text('Management'),
        ),
        backgroundColor: Colors.white,
        sideBar: SideBar(
          items: const [
            AdminMenuItem(
                title: 'Dashboard',
                icon: Icons.dashboard,
                route: DashboardScreen.routeName),
            AdminMenuItem(
                title: 'Courses',
                icon: CupertinoIcons.person_3,
                route: CourseScreen.routeName),
            AdminMenuItem(
                title: 'Statistical',
                icon: CupertinoIcons.money_dollar,
                route: WithdrawalScreen.routeName),
            AdminMenuItem(
                title: 'Ranking',
                icon: CupertinoIcons.star_fill,
                route: rankingScreen.routeName),
          ],
          selectedRoute: '',
          onSelected: (item) {
            screenSelector(item);
          },
        ),
        body: _selecttedItem);
  }
}
