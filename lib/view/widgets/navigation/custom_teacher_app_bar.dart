import 'package:flutter/material.dart';

// A custom bottom navigation bar designed for teachers
class CustomBottomNavigationTeacherBar extends StatelessWidget {
  final int currentIndex; // The currently selected index
  final ValueChanged<int> onTap; // Callback for handling item taps

  // Constructor to initialize required fields
  const CustomBottomNavigationTeacherBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Adding shadow to the navigation bar for visual elevation
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Subtle grey shadow
            spreadRadius: 1, // How far the shadow spreads
            blurRadius: 10, // Blurriness of the shadow
            offset: const Offset(0, -2), // Positioning above the bar
          ),
        ],
      ),
      // BottomNavigationBar for navigation between teacher-related sections
      child: BottomNavigationBar(
        items: const [
          // First tab: Learning section
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_filled), // Default icon
            activeIcon: Icon(Icons.play_circle_filled,
                size: 28), // Enlarged active icon
            label: 'Learning', // Label below the icon
            tooltip: 'Interactive Learning', // Tooltip on long press
          ),
          // Second tab: Schedule section
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            activeIcon: Icon(Icons.schedule, size: 28),
            label: 'Schedule',
            tooltip: 'Class Schedule',
          ),
          // Third tab: Courses section
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book, size: 28),
            label: 'Courses',
            tooltip: 'Browse Courses',
          ),
          // Fourth tab: Chat section
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble, size: 28),
            label: 'Chat',
            tooltip: 'Message Center',
          ),
        ],
        // Highlighted item index
        currentIndex: currentIndex,
        // Callback when an item is tapped
        onTap: onTap,
        // Customizing selected and unselected item styles
        selectedItemColor:
            Theme.of(context).primaryColor, // Color for selected item
        unselectedItemColor: Colors.grey, // Grey for unselected items
        selectedFontSize: 12, // Font size for selected label
        unselectedFontSize: 12, // Font size for unselected label
        type: BottomNavigationBarType.fixed, // Fixed positioning for all items
        backgroundColor: Colors.white, // White background
        elevation: 0, // Flat navigation bar
        showSelectedLabels: true, // Display labels for selected items
        showUnselectedLabels: true, // Display labels for unselected items
        enableFeedback: true, // Enable haptic feedback for item taps
      ),
    );
  }
}
