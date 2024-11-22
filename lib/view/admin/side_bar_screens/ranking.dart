import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class rankingScreen extends StatelessWidget {
  static const String routeName = '/rankingScreen';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Users')
          .where('rool', isEqualTo: 'Teacher') // Lọc chỉ giáo viên
          .snapshots(),
      builder: (context, teacherSnapshot) {
        if (teacherSnapshot.hasError) {
          return Center(child: Text('Error: ${teacherSnapshot.error}'));
        }

        if (!teacherSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top 5 Teachers',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 24),

                // Danh sách Top giáo viên
                _buildTopTeachersList(teacherSnapshot.data!.docs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopTeachersList(List<DocumentSnapshot> teachers) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _calculateTopTeachers(teachers),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final topTeachers = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topTeachers.length,
          itemBuilder: (context, index) {
            final teacher = topTeachers[index];
            final ranking = index + 1;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRankingColor(ranking),
                child: Text(
                  '$ranking',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                teacher['username'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${teacher['studentCount']} students enrolled'),
              trailing: Text(
                '${teacher['courseCount']} courses',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _calculateTopTeachers(
      List<DocumentSnapshot> teachers) async {
    List<Map<String, dynamic>> teacherStats = [];

    for (var teacherDoc in teachers) {
      final teacher = teacherDoc.data() as Map<String, dynamic>;
      final teacherId = teacherDoc.id;

      // Lấy danh sách ID các khóa học mà giáo viên này tạo
      final createdCourses = teacher['createdCourses'] ?? [];

      int totalStudents = 0;

      // Tính tổng số học sinh từ danh sách các khóa học
      for (var courseId in createdCourses) {
        final studentsSnapshot = await _firestore
            .collection('Users')
            .where('registeredCourses', arrayContains: courseId)
            .get();

        totalStudents += studentsSnapshot.docs.length;
      }

      teacherStats.add({
        'id': teacherId,
        'username': teacher['username'] ?? 'Unknown Teacher',
        'studentCount': totalStudents,
        'courseCount': createdCourses.length,
      });
    }

    // Sắp xếp theo số lượng học sinh giảm dần
    teacherStats.sort((a, b) => b['studentCount'].compareTo(a['studentCount']));

    // Lấy top 5 giáo viên
    return teacherStats.take(5).toList();
  }

  Color _getRankingColor(int ranking) {
    switch (ranking) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.blue;
    }
  }
}
