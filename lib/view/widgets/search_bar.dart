import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBarWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8.0),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to the search screen when the search bar is tapped
                Navigator.of(context).pushNamed('/findatutor');
              },
              // Placeholder text for the search bar
              child: const Text(
                'Search for ...',
                style: TextStyle(
                    color:
                        Colors.grey), // Grey color to indicate placeholder text
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
