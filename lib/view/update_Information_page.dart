import 'dart:io';
import 'package:fat_app/service/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/UserModel.dart' as AppUser;
import 'package:fat_app/Model/districts_and_wards.dart';
import 'package:fat_app/constants/constant_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() async {
            username = doc.get('username') as String? ?? '';
            role = doc.get('rool') as String? ?? ''; // Get role from Firestore
            _roleController.text = role; // Set role in controller
            _currentProfileImageUrl = doc.get('profileImage') as String?;
            _userNameController.text = doc.get('username') as String? ?? '';
            _classNameController.text = doc.get('class') as String? ?? '';
            _phoneNumberController.text =
                doc.get('phoneNumber') as String? ?? '';
            // Parse position if it exists
            String position = doc.get('position') as String? ?? '';

            if (position.isNotEmpty) {
              List<String> parts = position.split(', ');
              if (parts.length >= 4) {
                _selectedWard = parts[0];
                _selectedDistrict = parts[1];
                _addressController.text = parts[3];
                _phoneNumberController.text = parts[4];
              }
            }
          });
          print('Logged in user: $username');
        } else {
          print('User document does not exist');
        }
      } else {
        print('No user is currently logged in');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _currentProfileImageUrl;

    try {
      setState(() => _isUploading = true);

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String fileName =
          'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Reference storageRef =
          FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);

      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
        _currentProfileImageUrl =
            downloadUrl; // Update the current profile image URL
      });
      return downloadUrl;
    } catch (e) {
      setState(() => _isUploading = false);
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image')),
      );
      return null;
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() &&
        _selectedDistrict != null &&
        _selectedWard != null) {
      String? imageUrl = await _uploadImage();

      User? user = FirebaseAuth.instance.currentUser;
      AppUser.UserModel newUser = AppUser.UserModel(
        userName: _userNameController.text,
        userClass: _classNameController.text,
        position:
            '$_selectedWard, $_selectedDistrict, Đà Nẵng, ${_addressController.text}',
        profileImage: (imageUrl ?? _currentProfileImageUrl) ?? '',
        email: user?.email ?? '',
        role: role,
        phoneNumber: _phoneNumberController.text,
        createdCourses: [],
      );

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        bool userExists = await _userService.checkUserExits(userId);
        if (userExists) {
          await _userService.updateUser(userId, newUser);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Information updated successfully')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            interactlearningpage,
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
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
        child: Container(
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
    if (_isUploading) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
      );
    }

    if (_currentProfileImageUrl != null) {
      return Image.network(
        _currentProfileImageUrl!,
        fit: BoxFit.cover,
        width: 140,
        height: 140,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      );
    }

    return Image.asset(
      'images/students.png',
      fit: BoxFit.cover,
      width: 140,
      height: 140,
    );
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
          // Added role input field
          controller: _roleController,
          label: 'Role',
          icon: Icons.work_outline, // Changed icon to be more role-appropriate
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
