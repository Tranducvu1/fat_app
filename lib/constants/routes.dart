import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/constants/constant_routes.dart';
import 'package:fat_app/view/Student/Chatroom/chat_rooms_page.dart';
import 'package:fat_app/view/Student/MainPage/class_schedule_page.dart';
import 'package:fat_app/view/Student/MainPage/course_page.dart';
import 'package:fat_app/view/Student/MainPage/interact_learning_page.dart';
import 'package:fat_app/view/Student/Chapter/list_lecture_page.dart';
import 'package:fat_app/view/Student/MainPage/tutor_list_page.dart';
import 'package:fat_app/view/Teacher/MainPage/Interact_learning_teacher_page.dart';
import 'package:fat_app/view/Teacher/MainPage/class_schedule_page.dart';
import 'package:fat_app/view/Teacher/Courses/course_teacher_page.dart';
import 'package:fat_app/view/Teacher/MainPage/tutor_chat_rooms_page%20.dart';
import 'package:fat_app/view/payment/confirm_method_screen.dart';
import 'package:fat_app/view/update_Information_page.dart';
import 'package:fat_app/view_auth/EmailVerify.dart';
import 'package:fat_app/view_auth/login_view.dart';
import 'package:fat_app/view_auth/register_view.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> appRoutes = {
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
  interactlearningpage: (context) => const InteractLearningPage(),
  loginRoutes: (context) => LoginPage(),
  registerRoutes: (context) => Register(),
  emailverifyRoute: (context) => const EmailVerify(),
  paymentRoutes: (context) => PaymentMethodScreen(),
  updateinformationRoutes: (context) => UpdateInformationPage(),
  interactlearninteachergpage: (context) => const InteractLearningTeacherPage(),
  chatpage: (context) => ChatRoomsPage(),
  chatteacherPage: (context) => TutorChatRoomsPage(),
  classscheduleteacherpage: (context) => const classscheduleteacherPage(),
  courseteacherpage: (context) => courseteacherPage(
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
  listlectureRoutes: (context) => LectureListScreen(
        chapterId: [0],
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
          chapterId: ['0'],
        ),
      ),
};
