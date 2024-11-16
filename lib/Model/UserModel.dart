class UserModel {
  final String userName;
  final String email;
  final String role;
  final String userClass;
  final String position;
  final String? profileImage;
  final String phoneNumber;
  final List<String> createdCourses;

  UserModel(
      {required this.userName,
      required this.email,
      required this.role,
      required this.userClass,
      required this.position,
      this.profileImage,
      required this.phoneNumber,
      required this.createdCourses});

  Map<String, dynamic> toMap() {
    return {
      'username': userName,
      'email': email,
      'rool': role,
      'class': userClass,
      'position': position,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'createdCourses': createdCourses,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['rool'] ?? '',
      userClass: map['class'] ?? '',
      position: map['position'] ?? '',
      profileImage: map['profileImage'],
      phoneNumber: map['phoneNumber'] ?? '',
      createdCourses: List<String>.from(map['createdCourses'] ?? []),
    );
  }

  @override
  String toString() {
    return 'User{username: $userName, email: $email, rool: $role, class: $userClass, position: $position , profileImage: $profileImage, phoneNumber: $phoneNumber}';
  }
}
