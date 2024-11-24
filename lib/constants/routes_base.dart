import 'package:fat_app/constants/constant_routes.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/payment/confirm_method_screen.dart';
import 'package:fat_app/view/update_Information_page.dart';
import 'package:fat_app/view_auth/EmailVerify.dart';
import 'package:fat_app/view_auth/login_view.dart';
import 'package:fat_app/view_auth/register_view.dart';

/// Common Routes (Base Routes)
Map<String, WidgetBuilder> routesBase = {
  loginRoutes: (context) => LoginPage(),
  registerRoutes: (context) => Register(),
  emailverifyRoute: (context) => const EmailVerify(),
  paymentRoutes: (context) => PaymentMethodScreen(),
  updateinformationRoutes: (context) => UpdateInformationPage(),
};
