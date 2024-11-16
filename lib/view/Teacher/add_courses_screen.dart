import 'package:fat_app/service/courses_service.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCoursesScreen extends StatefulWidget {
  const AddCoursesScreen({Key? key}) : super(key: key);

  @override
  _AddCoursesScreenState createState() => _AddCoursesScreenState();
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final CourseService _courseService = CourseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Course course = Course(
          id: '',
          teacher: _teacherController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          price: double.parse(_priceController.text),
          subject: _subjectController.text,
          description: _descriptionController.text,
          creatorId: user.uid,
          createdAt: Timestamp.now(),
          chapterId: [],
        );

        try {
          await _courseService.saveCourse(course);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course added successfully!')),
          );
          Navigator.of(context).pop();
        } catch (e) {
          debugPrint('Error saving course: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add course')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
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
                    onPressed: _saveCourse,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Submit'),
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
