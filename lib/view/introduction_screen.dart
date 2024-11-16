import 'package:fat_app/intro_screens/intro_page1.dart';
import 'package:fat_app/intro_screens/intro_page2.dart';
import 'package:fat_app/intro_screens/intro_page3.dart';
import 'package:fat_app/view_auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controllerPage;
  bool onLastPage = false;

  @override
  void initState() {
    super.initState();
    _controllerPage = PageController();
  }

  @override
  void dispose() {
    _controllerPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controllerPage,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      if (_controllerPage.page! > 0) {
                        _controllerPage.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(
                      "Skip",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                SmoothPageIndicator(controller: _controllerPage, count: 3),
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return LoginPage();
                          }));
                        },
                        child: Text("Done",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)))
                    : GestureDetector(
                        onTap: () {
                          // if (_controllerPage.page! < 2) {
                          _controllerPage.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                          // }
                        },
                        child: Text("Next",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
