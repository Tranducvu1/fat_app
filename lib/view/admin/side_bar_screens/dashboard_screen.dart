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
        title: Text('Dash board'),
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
                    Text("Log out"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users available.'));
          }
          var users = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(0.5), // Column "User ID"
                  1: FlexColumnWidth(2), // Column "User name"
                  2: FlexColumnWidth(2), // Column "Email "
                  3: FlexColumnWidth(1), // Column "Role"
                  4: FlexColumnWidth(1), // Column "Edit"
                  5: FlexColumnWidth(1), // Column "Delete"
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'User name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Role',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Display user from Firebase
                  ...List.generate(users.length, (index) {
                    var user = users[index].data() as Map<String, dynamic>;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            // Add Center widget to align text in the middle
                            child: Text(
                              (index + 1).toString(),
                              textAlign: TextAlign
                                  .center, // Align text horizontally in the center
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user['username'] ?? 'N/A'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user['email'] ?? 'N/A'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user['rool']?.toString() ?? 'N/A'),
                        ),
                        // Edit button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _editUser(context, users[index].id)),
                        ),
                        // Delete button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteUser(context, users[index].id);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
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
