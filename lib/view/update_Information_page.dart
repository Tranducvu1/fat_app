import 'dart:io';
import 'package:fat_app/service/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fat_app/Model/districts_and_wards.dart';
import 'package:flutter/material.dart';

class UpdateInformationPage extends StatefulWidget {
  @override
  _UpdateInformationPageState createState() => _UpdateInformationPageState();
}

class _UpdateInformationPageState extends State<UpdateInformationPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedDistrict;
  String role = '';
  String? _selectedWard;
  String username = '';
  String? _currentProfileImageUrl;
  File? _imageFile;
  bool _isUploading = false;
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  final Map<String, List<String>> _districtsAndWards =
      DistrictsAndWards.MapDN();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _classNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // ... (existing code)
  }

  Future<void> _pickImage() async {
    // ... (existing code)
  }

  Future<String?> _saveImageLocally() async {
    // ... (existing code)
  }

  Future<String?> _uploadImage() async {
    // ... (existing code)
  }

  Future<void> _handleSubmit() async {
    // ... (existing code)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          username.isNotEmpty ? username : 'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                SizedBox(height: 32),
                _buildProfileImage(),
                SizedBox(height: 40),
                _buildInputFields(),
                SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Update Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Complete your profile information',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade300, Colors.blue.shade600],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  spreadRadius: 4,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(3),
              child: ClipOval(
                child: _buildProfileImageContent(),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageContent() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    } else if (_currentProfileImageUrl != null &&
        File(_currentProfileImageUrl!).existsSync()) {
      return Image.file(
        File(_currentProfileImageUrl!),
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    } else {
      return Image.asset(
        'images/default-avatar.png',
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    }
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildInputField(
          controller: _userNameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          hint: 'Enter your full name',
        ),
        SizedBox(height: 20),
        _buildInputField(
          controller: _roleController,
          label: 'Role',
          icon: Icons.work_outline,
          hint: 'Your role',
        ),
        SizedBox(height: 20),
        _buildInputField(
          controller: _classNameController,
          label: 'Class',
          icon: Icons.school_outlined,
          hint: 'Enter your class',
        ),
        SizedBox(height: 20),
        _buildInputField(
          controller: _phoneNumberController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 20),
        _buildDropdownField(
          value: _selectedDistrict,
          items: _districtsAndWards.keys.toList(),
          label: 'District',
          icon: Icons.location_city_outlined,
          onChanged: (value) {
            setState(() {
              _selectedDistrict = value;
              _selectedWard = null;
            });
          },
        ),
        SizedBox(height: 20),
        if (_selectedDistrict != null)
          _buildDropdownField(
            value: _selectedWard,
            items: _districtsAndWards[_selectedDistrict]!,
            label: 'Ward',
            icon: Icons.map_outlined,
            onChanged: (value) {
              setState(() {
                _selectedWard = value;
              });
            },
          ),
        SizedBox(height: 20),
        _buildInputField(
          controller: _addressController,
          label: 'Street Address',
          icon: Icons.home_outlined,
          hint: 'Enter street and house number',
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
            isExpanded: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isUploading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isUploading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
