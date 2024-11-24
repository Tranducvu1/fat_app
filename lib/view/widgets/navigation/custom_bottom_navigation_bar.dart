import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex; // Index of the currently selected item
  final ValueChanged<int> onTap; // Callback for handling item taps

  // Constructor to initialize the required fields
  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add shadow for a floating effect
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Light grey shadow
            spreadRadius: 1, // Shadow spread
            blurRadius: 10, // Shadow blur
            offset: const Offset(0, -2), // Shadow position
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const [
          // Learning Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_filled), // Default icon
            activeIcon: Icon(Icons.play_circle_filled,
                size: 28), // Enlarged active icon
            label: 'Learning', // Label below the icon
            tooltip: 'Interactive Learning', // Tooltip when long-pressed
          ),
          // Schedule Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            activeIcon: Icon(Icons.schedule, size: 28),
            label: 'Schedule',
            tooltip: 'Class Schedule',
          ),
          // Courses Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book, size: 28),
            label: 'Courses',
            tooltip: 'Browse Courses',
          ),
          // Chat Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble, size: 28),
            label: 'Chat',
            tooltip: 'Message Center',
          ),
          // Find Tutor Tab
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search_outlined),
            activeIcon: Icon(Icons.person_search, size: 28),
            label: 'Find Tutor',
            tooltip: 'Find a Tutor',
          ),
        ],
        currentIndex: currentIndex, // Highlighted index
        onTap: onTap, // Function to handle taps
        selectedItemColor: Theme.of(context).primaryColor, // Highlight color
        unselectedItemColor: Colors.grey, // Color for unselected items
        selectedFontSize: 12, // Font size for the selected tab's label
        unselectedFontSize: 12, // Font size for unselected labels
        type:
            BottomNavigationBarType.fixed, // Ensure all tabs are always visible
        backgroundColor: Colors.white, // White background for a clean look
        elevation: 0, // No elevation for a flat design
        showSelectedLabels: true, // Display labels for the selected tab
        showUnselectedLabels: true, // Display labels for unselected tabs
        enableFeedback:
            true, // Enable haptic feedback for better user experience
      ),
    );
  }
}
