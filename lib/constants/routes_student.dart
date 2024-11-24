import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/UserModel.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/constants/constant_routes.dart';
import 'package:fat_app/view/Student/Chapter/question_page.dart';
import 'package:fat_app/view/Student/MainPage/tutor_detail_page.dart';
import 'package:fat_app/view/Teacher/Chatroom/teacher_screen.dart';
import 'package:fat_app/view/payment/confirm_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/Student/Chatroom/chat_rooms_page.dart';
import 'package:fat_app/view/Student/MainPage/class_schedule_page.dart';
import 'package:fat_app/view/Student/MainPage/course_page.dart';
import 'package:fat_app/view/Student/MainPage/interact_learning_page.dart';
import 'package:fat_app/view/Student/Chapter/list_lecture_page.dart';
import 'package:fat_app/view/Student/MainPage/tutor_list_page.dart';

/// Student Routes
Map<String, WidgetBuilder> routesStudent = {
  classschedulePage: (context) => const ClassSchedulePage(),
  coursepage: (context) => CoursePage(
        course: Course(
          id: '',
          subject: '',
          teacher: '',
          startDate: '',
          endDate: '',
          price: 0.0,
          description: '',
          creatorId: '',
          createdAt: Timestamp.now(),
          chapterId: [],
        ),
      ),
  fatutorpage: (context) => const TutorListPage(),
  videoRoutes: (context) => const TeacherScreen(
        lessonId: 0,
      ),
  interactlearningpage: (context) => const InteractLearningPage(),
  chatpage: (context) => ChatRoomsPage(),
  paymentRoutes: (context) => PaymentMethodScreen(),
  informationTutor: (context) => TutorDetailPage(
        course: Course(
          id: '',
          subject: '',
          teacher: '',
          startDate: '',
          endDate: '',
          price: 0.0,
          description: '',
          creatorId: '',
          createdAt: Timestamp.now(),
          chapterId: [],
        ),
        user: UserModel(
          email: '',
          userName: '',
          role: '',
          userClass: '',
          position: '',
          phoneNumber: '',
          createdCourses: [],
        ),
      ),
  questionRoutes: (context) => QuestionPage(
        lessonId: [],
      ),
};
