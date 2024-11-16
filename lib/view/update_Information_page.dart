import 'dart:io';
import 'package:fat_app/service/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/UserModel.dart' as AppUser;
import 'package:fat_app/Model/districts_and_wards.dart';
import 'package:fat_app/constants/routes.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateInformationPage extends StatefulWidget {
  @override
  _UpdateInformationPageState createState() => _UpdateInformationPageState();
}

class _UpdateInformationPageState extends State<UpdateInformationPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedDistrict;
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
          setState(() {
            username = doc.get('username') as String? ?? '';
            _currentProfileImageUrl = doc.get('profileImage') as String?;
            _userNameController.text = doc.get('username') as String? ?? '';
            _classNameController.text = doc.get('userClass') as String? ?? '';
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
        role: 'user',
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
      appBar: AppBar(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!) as ImageProvider
                  : _currentProfileImageUrl != null
                      ? NetworkImage(_currentProfileImageUrl!)
                      : AssetImage('images/students.png') as ImageProvider,
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : null,
            ),
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          username.isNotEmpty ? username : 'User',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Update information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildProfileImageSection(),
              SizedBox(height: 20),
              _buildTextField(
                controller: _userNameController,
                hintText: 'Enter username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _classNameController,
                hintText: 'Class',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your class';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _phoneNumberController,
                hintText: 'Phone number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildDistrictDropdown(),
              SizedBox(height: 16),
              _buildWardDropdown(),
              SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                hintText: 'Enter your street and house number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isUploading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Stack(
            children: [
              ClipOval(
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : _currentProfileImageUrl != null
                        ? Image.network(
                            _currentProfileImageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            'images/students.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _pickImage,
                  ),
                ),
              ),
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_imageFile != null)
          TextButton(
            onPressed: () {
              setState(() {
                _imageFile = null;
              });
            },
            child: Text('Remove selected image'),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.lightBlueAccent.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.lightBlueAccent.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text('Select District'),
      value: _selectedDistrict,
      isExpanded: true,
      items: _districtsAndWards.keys.map((String district) {
        return DropdownMenuItem<String>(
          value: district,
          child: Text(district),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedDistrict = newValue;
          _selectedWard = null;
        });
      },
    );
  }

  Widget _buildWardDropdown() {
    if (_selectedDistrict == null) {
      return Container();
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.lightBlueAccent.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text('Select Ward'),
      value: _selectedWard,
      isExpanded: true,
      items: _districtsAndWards[_selectedDistrict]!.map((String ward) {
        return DropdownMenuItem<String>(
          value: ward,
          child: Text(ward),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedWard = newValue;
        });
      },
    );
  }
}
