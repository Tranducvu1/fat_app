import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationTap;

  const CustomAppBar({
    Key? key,
    required this.username,
    required this.onAvatarTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/updateinformation');
            },
            child: const CircleAvatar(
              backgroundImage: AssetImage('images/students.png'),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            username.isNotEmpty ? username : 'User',
            style: const TextStyle(color: Colors.black),
          ),
          const Spacer(),
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications),
            color: Colors.black,
          ),
        ],
      ),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
