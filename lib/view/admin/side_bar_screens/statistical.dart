import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WithdrawalScreen extends StatelessWidget {
  static const String routeName = '/WithdrawalScreen';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Format currency
  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Courses').snapshots(),
      builder: (context, courseSnapshot) {
        if (courseSnapshot.hasError) {
          return Center(child: Text('Error: ${courseSnapshot.error}'));
        }

        if (!courseSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Revenue Overview Cards
                _buildRevenueOverview(courseSnapshot.data!.docs),

                const SizedBox(height: 24),

                // Bar Chart
                _buildRevenueChart(courseSnapshot.data!.docs),

                const SizedBox(height: 24),

                // Detailed Course List
                _buildCourseList(courseSnapshot.data!.docs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueOverview(List<DocumentSnapshot> courses) {
    double totalRevenue = 0;
    int totalStudents = 0;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _calculateRevenueData(courses),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final revenueData = snapshot.data!;

        // Calculate totals
        for (var data in revenueData) {
          totalRevenue += data['revenue'] as double;
          totalStudents += data['studentCount'] as int;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Total Revenue',
                  currencyFormatter.format(totalRevenue),
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOverviewCard(
                  'Total Students',
                  totalStudents.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildRevenueChart(List<DocumentSnapshot> courses) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _calculateRevenueData(courses),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final revenueData = snapshot.data!;
        final maxRevenue = revenueData.isEmpty
            ? 0.0
            : revenueData
                .map((d) => d['revenue'] as double)
                .reduce((a, b) => a > b ? a : b);

        if (revenueData.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxRevenue * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8.0),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${revenueData[groupIndex]['subject']}\n${currencyFormatter.format(rod.toY)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= revenueData.length) {
                        return const Text('');
                      }
                      final subject =
                          revenueData[value.toInt()]['subject'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _truncateString(subject, 10),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        currencyFormatter.format(value),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxRevenue / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              barGroups: revenueData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data['revenue'] as double,
                      width: 20,
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseList(List<DocumentSnapshot> courses) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _calculateRevenueData(courses),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final revenueData = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: revenueData.map((data) {
              return ListTile(
                title: Text(
                  data['subject'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${data['studentCount']} students'),
                trailing: Text(
                  currencyFormatter.format(data['revenue']),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _calculateRevenueData(
      List<DocumentSnapshot> courses) async {
    List<Map<String, dynamic>> revenueData = [];

    for (var courseDoc in courses) {
      final course = courseDoc.data() as Map<String, dynamic>;
      final courseId = courseDoc.id;

      // Get number of students
      final userSnapshot = await _firestore
          .collection('Users')
          .where('registeredCourses', arrayContains: courseId)
          .get();

      final studentCount = userSnapshot.docs.length;
      final price = (course['price'] as num).toDouble();
      final revenue = studentCount * price;

      revenueData.add({
        'subject': course['subject'],
        'studentCount': studentCount,
        'price': price,
        'revenue': revenue,
      });
    }

    // Sort by revenue in descending order
    revenueData.sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

    return revenueData;
  }
}
