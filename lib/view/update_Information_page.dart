import 'dart:io';
import 'package:fat_app/service/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fat_app/Model/districts_and_wards.dart';
import 'package:flutter/material.dart';

// Stateful widget for updating user information
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
  String? _selectedDistrict; // Holds the selected district
  String role = ''; // User's role
  String? _selectedWard; // Holds the selected ward
  String username = ''; // User's name
  String? _currentProfileImageUrl; // URL of the current profile image
  File? _imageFile; // Holds the image file selected by the user
  bool _isUploading = false; // Flag to track image upload status
  final UserService _userService = UserService(); // Service to handle user data
  final ImagePicker _picker =
      ImagePicker(); // Image picker for selecting photos
  final Map<String, List<String>> _districtsAndWards =
      DistrictsAndWards.MapDN(); // Districts and wards data
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page is initialized
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _userNameController.dispose();
    _classNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Loads the current user data to populate the form fields
  Future<void> _loadUserData() async {
    // Code to load user data from a backend service or database
  }

  // Opens image picker to allow the user to pick a profile image
  Future<void> _pickImage() async {
    // Code for image picking logic
  }

  // Saves the selected image to local storage
  Future<String?> _saveImageLocally() async {
    // Code to save image locally
  }

  // Uploads the selected image to a remote server
  Future<String?> _uploadImage() async {
    // Code for uploading image
  }

  // Handles form submission to update the user's profile
  Future<void> _handleSubmit() async {
    // Code for submitting the form data
  }

  @override
  Widget build(BuildContext context) {
    // Builds the UI for the page
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
                _buildHeader(), // Builds header section of the page
                SizedBox(height: 32),
                _buildProfileImage(), // Builds the profile image section
                SizedBox(height: 40),
                _buildInputFields(), // Builds the input fields for user data
                SizedBox(height: 40),
                _buildSubmitButton(), // Builds the submit button for form submission
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the header section with title and subtitle
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

  // Builds the profile image display and edit option
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
              onTap: _pickImage, // Calls the image picking function
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

  // Determines the profile image content to display
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

  // Builds the input fields section with validation
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
              _selectedWard = null; // Reset ward when district is changed
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

  // Builds a generic input field with validation
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  // Builds a dropdown field for selecting district or ward
  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }

  // Builds the submit button for updating user information
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isUploading
          ? null
          : _handleSubmit, // Prevent button click during upload
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
      ),
      child: _isUploading
          ? CircularProgressIndicator(
              color: Colors.white) // Show loading indicator when uploading
          : Text('Update Profile', style: TextStyle(fontSize: 18)),
    );
  }
}
