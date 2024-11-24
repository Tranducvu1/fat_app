import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username; // Username to display on the AppBar
  final VoidCallback onAvatarTap; // Action when avatar is tapped
  final VoidCallback
      onNotificationTap; // Action when notification icon is tapped

  // Constructor
  const CustomAppBar({
    Key? key,
    required this.username,
    required this.onAvatarTap,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Set AppBar background color to white
      elevation: 2, // Slight elevation for depth
      title: Row(
        children: [
          // Avatar with tap functionality
          GestureDetector(
            onTap: onAvatarTap,
            child: const CircleAvatar(
              radius: 20,
              backgroundImage:
                  AssetImage('images/students.png'), // Avatar image
            ),
          ),
          const SizedBox(width: 10), // Space between avatar and username
          // Display username or a fallback 'User' text
          Text(
            username.isNotEmpty ? username : 'User',
            style: const TextStyle(
              color: Colors.black, // Black text color
              fontSize: 16, // Font size for the username
              fontWeight: FontWeight.w500, // Slightly bold
            ),
          ),
          const Spacer(), // Push notification icon to the right
          // Notification button
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications),
            color: Colors.black, // Black notification icon
          ),
        ],
      ),
      automaticallyImplyLeading: false, // Remove default back button
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(56.0); // Default app bar height
}
