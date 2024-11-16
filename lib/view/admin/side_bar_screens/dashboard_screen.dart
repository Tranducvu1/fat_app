import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/service/user_service.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/DashboardScreen';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (value) {
              if (value == 1) {
                UserService().logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black), // Icon log out
                    SizedBox(width: 8),
                    Text("Log out"), // Button log out
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading user data"));
                  }

                  final users = snapshot.data?.docs ?? [];

                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Username')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Edit')),
                      DataColumn(label: Text('Delete')),
                    ],
                    rows: List<DataRow>.generate(users.length, (index) {
                      final user = users[index];
                      final id = index + 1; // Auto-incrementing ID
                      final username = user['username'] ?? 'N/A';
                      final email = user['email'] ?? 'N/A';
                      final role = user['rool'] ?? 'N/A';

                      return DataRow(cells: [
                        DataCell(Text(id.toString())),
                        DataCell(Text(username)),
                        DataCell(Text(email)),
                        DataCell(Text(role)),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Handle edit functionality
                              _editUser(context, user.id);
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Handle delete functionality
                              _deleteUser(context, user.id);
                            },
                          ),
                        ),
                      ]);
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to edit a user
  void _editUser(BuildContext context, String userId) {
    // Implement your edit logic here, e.g., navigate to an edit screen
    print('Editing user with ID: $userId');
  }

  // Function to delete a user
  Future<void> _deleteUser(BuildContext context, String userId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).delete();
    }
  }
}
