import 'package:fat_app/view/admin/side_bar_screens/courses_screen.dart';
import 'package:fat_app/view/admin/side_bar_screens/dashboard_screen.dart';
import 'package:fat_app/view/admin/side_bar_screens/withdrawal_screen.dart';
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
          title: Text('Management'),
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
                title: 'Withdrawal',
                icon: CupertinoIcons.money_dollar,
                route: WithdrawalScreen.routeName),
          ],
          selectedRoute: '',
          onSelected: (item) {
            screenSelector(item);
          },
          header: Container(
            height: 50,
            width: double.infinity,
            color: const Color(0xff444444),
            child: const Center(
              child: Text(
                'FAT App',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          footer: Container(
            height: 50,
            width: double.infinity,
            color: const Color(0xff444444),
            child: const Center(
              child: Text(
                'footer',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: _selecttedItem);
  }
}
