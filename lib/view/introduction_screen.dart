import 'package:fat_app/intro_screens/intro_page1.dart';
import 'package:fat_app/intro_screens/intro_page2.dart';
import 'package:fat_app/intro_screens/intro_page3.dart';
import 'package:fat_app/view_auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Stateful widget for the onboarding screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controllerPage; // Controller to manage the PageView
  bool onLastPage = false; // Tracks if the user is on the last onboarding page

  @override
  void initState() {
    super.initState();
    _controllerPage = PageController(); // Initialize the PageController
  }

  @override
  void dispose() {
    _controllerPage
        .dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView to swipe between onboarding pages
          PageView(
            controller: _controllerPage,
            onPageChanged: (index) {
              // Updates the state when the page changes
              setState(() {
                onLastPage = (index == 2); // Marks if the last page is reached
              });
            },
            children: [
              IntroPage1(), // First intro page
              IntroPage2(), // Second intro page
              IntroPage3(), // Third intro page
            ],
          ),
          // Positioned elements on top of the PageView
          Container(
            alignment: Alignment(0, 0.75), // Align at the bottom of the screen
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // "Skip" button to jump to the last page
                GestureDetector(
                  onTap: () {
                    if (_controllerPage.page! > 0) {
                      // Navigates to the previous page
                      _controllerPage.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // SmoothPageIndicator for page navigation
                SmoothPageIndicator(
                  controller: _controllerPage,
                  count: 3, // Total number of pages
                ),
                // Conditional button (Next or Done)
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          // Navigate to the LoginPage when "Done" is tapped
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return LoginPage();
                          }));
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          // Navigate to the next page when "Next" is tapped
                          _controllerPage.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
