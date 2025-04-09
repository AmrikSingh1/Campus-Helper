import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import 'auth/sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Subject-Wise Resources",
      description: "Access notes, PPTs, books, and video tutorials organized by subject for easy learning.",
      animationPath: "assets/lottie/Subject-Wise-Resources.json",
    ),
    OnboardingPage(
      title: "Assignment Tracker",
      description: "Stay on top of all your assignments with deadlines, status updates and submission tools.",
      animationPath: "assets/lottie/Assignment-&-Submission-Tracker.json",
    ),
    OnboardingPage(
      title: "Semester Timeline",
      description: "View your complete academic calendar with class schedules, exams and important events.",
      animationPath: "assets/lottie/Semester-Timeline.json",
    ),
    OnboardingPage(
      title: "Exam Preparation",
      description: "Practice with mock tests, track your progress and access important question banks.",
      animationPath: "assets/lottie/Exam-Preparation-Zone.json",
    ),
    OnboardingPage(
      title: "Grade Tracker",
      description: "Monitor your academic performance with visual analytics of your grades and progress.",
      animationPath: "assets/lottie/Grade-Tracker-&-Progress.json",
    ),
    OnboardingPage(
      title: "Start Your Journey",
      description: "All the tools you need for academic success in one app. Let's get started!",
      animationPath: "assets/lottie/Start-Your-Campus-Journey.json",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              if (_currentPage < _pages.length - 1)
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _navigateToSignIn,
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              
              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Page indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 16,
                    dotColor: Colors.white.withOpacity(0.5),
                    activeDotColor: Colors.white,
                  ),
                ),
              ),
              
              // Next or Get Started button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0),
                child: _currentPage == _pages.length - 1
                    ? CustomButton(
                        text: 'Get Started',
                        onPressed: _navigateToSignIn,
                      )
                    : CustomButton(
                        text: 'Next',
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation
          Lottie.asset(
            page.animationPath,
            width: 280,
            height: 280,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String animationPath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.animationPath,
  });
} 