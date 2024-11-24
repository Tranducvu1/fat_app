import 'package:flutter/material.dart';
import 'routes_base.dart';
import 'routes_teacher.dart';
import 'routes_student.dart';

/// Combine all the routes into one central map
Map<String, WidgetBuilder> appRoutes = {
  // Common Routes (Base)
  ...routesBase,

  // Student Routes
  ...routesStudent,

  // Teacher Routes
  ...routesTeacher,
};

//auth
const loginRoutes = '/login';
const registerRoutes = '/register';
const notesRoutes = '/notes';
const emailverifyRoute = '/emailverify';
const updateinformationRoutes = '/updateinformation';
//page student
const coursepage = '/course';
const tutorPage = '/tutorpage';
const interactlearningpage = '/interactlearning';
const classschedulePage = '/classschedule';
const fatutorpage = '/findatutor';
const chatpage = '/chat';
const paymentRoutes = '/payment';
const informationTutor = '/informationTutor';
const questionRoutes = '/question';
const videoRoutes = '/video';
const joinlive = '/joinlive';

//page teacher
const courseteacherpage = '/teachercourse';
const interactlearninteachergpage = '/teacherinteractlearning';
const classscheduleteacherpage = '/teacherclassschedule';
const chatteacherPage = '/teacherchat';
const tutorchatpage = '/tutorchat';
const listlectureteacherRoutes = '/listlectureteacher';
const teachervideo = '/teachervideo';
const addCourses = '/addCoursesScreen';
const addChapter = '/addChapterScreen';
const addLesson = '/addLesssonScreen';
const addQuestion = '/addQuestionScreen';
