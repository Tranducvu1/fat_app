import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/constants/constant_routes.dart';
import 'package:fat_app/view/Student/Chapter/list_lecture_page.dart';
import 'package:fat_app/view/Student/Chapter/question_page.dart';
import 'package:fat_app/view/Teacher/Chapter/add_chapter_form.dart';
import 'package:fat_app/view/Teacher/Chatroom/teacher_screen.dart';
import 'package:fat_app/view/Teacher/Courses/add_courses_screen.dart';
import 'package:fat_app/view/Teacher/Lesson/add_lesson_form.dart';
import 'package:fat_app/view/Teacher/MainPage/tutor_chat_rooms_page%20.dart';
import 'package:fat_app/view/Teacher/question/add_question_page.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/Teacher/MainPage/Interact_learning_teacher_page.dart';
import 'package:fat_app/view/Teacher/MainPage/class_schedule_page.dart';
import 'package:fat_app/view/Teacher/Courses/course_teacher_page.dart';

/// Teacher Routes
Map<String, WidgetBuilder> routesTeacher = {
  interactlearninteachergpage: (context) => const InteractLearningTeacherPage(),
  classscheduleteacherpage: (context) => const ClassScheduleTeacherPage(),
  chatteacherPage: (context) => TutorChatRoomsPage(),
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
  listlectureteacherRoutes: (context) => LectureListScreen(
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
  teachervideo: (context) => const TeacherScreen(
        lessonId: 0,
      ),
  addCourses: (context) => const AddCoursesScreen(),
  addChapter: (context) => AddChapterForm(
        onChapterAdded: () {},
        id: '',
      ),
  addLesson: (context) => AddLessonForm(
        chapterId: 0,
        onLessonAdded: () {},
      ),
  addQuestion: (context) => const AddQuestionPage(
        lessonId: '',
      ),
  questionRoutes: (context) => QuestionPage(
        lessonId: [],
      ),
};
