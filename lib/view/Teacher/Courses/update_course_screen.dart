import 'package:fat_app/service/courses_service.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateCoursesScreen extends StatefulWidget {
  final Course course;

  const UpdateCoursesScreen({Key? key, required this.course}) : super(key: key);

  @override
  _UpdateCoursesScreenState createState() => _UpdateCoursesScreenState();
}

class _UpdateCoursesScreenState extends State<UpdateCoursesScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _teacherController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _priceController;
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;

  final CourseService _courseService = CourseService();

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu hiện tại của khóa học
    _teacherController = TextEditingController(text: widget.course.teacher);
    _startDateController = TextEditingController(text: widget.course.startDate);
    _endDateController = TextEditingController(text: widget.course.endDate);
    _priceController =
        TextEditingController(text: widget.course.price.toString());
    _subjectController = TextEditingController(text: widget.course.subject);
    _descriptionController =
        TextEditingController(text: widget.course.description);
  }

  @override
  void dispose() {
    _teacherController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _priceController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = '${pickedDate.toLocal()}'.split(' ')[0];
    }
  }

  Future<void> _updateCourse() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Cập nhật thông tin khóa học
        Course updatedCourse = Course(
          id: widget.course.id, // Sử dụng ID của khóa học hiện tại
          teacher: _teacherController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          price: double.parse(_priceController.text),
          subject: _subjectController.text,
          description: _descriptionController.text,
          creatorId: widget.course.creatorId,
          createdAt: widget.course.createdAt,
          chapterId: widget.course.chapterId,
        );

        await _courseService.updateCourse(updatedCourse);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully!')),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        debugPrint('Error updating course: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update course')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Course'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'Enter subject',
              ),
              _buildTextField(
                controller: _startDateController,
                label: 'Start Date',
                hint: 'Select start date',
                readOnly: true,
                onTap: () => _selectDate(_startDateController),
              ),
              _buildTextField(
                controller: _endDateController,
                label: 'End Date',
                hint: 'Select end date',
                readOnly: true,
                onTap: () => _selectDate(_endDateController),
              ),
              _buildTextField(
                controller: _teacherController,
                label: 'Teacher',
                hint: 'Enter teacher\'s name',
              ),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                hint: 'Enter price',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter course description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: _updateCourse, // Gọi hàm cập nhật
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
