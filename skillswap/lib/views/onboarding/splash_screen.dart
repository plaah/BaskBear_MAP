import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<_SplashSlide> slides = [
    _SplashSlide(
      assetPath: 'assets/p1.jpg',
      title: 'SkillSwap',
      caption: 'Master new skills one-on-one, at your own pace',
    ),
    _SplashSlide(
      assetPath: 'assets/p2.jpg',
      title: 'SkillSwap',
      caption: 'Connect with real mentors and unleash your creativity',
    ),
    _SplashSlide(
      assetPath: 'assets/p3.jpg',
      title: 'SkillSwap',
      caption: 'Learn anything, anytime—on yourschedule',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _goToNextSlide();
    });
  }

  void _goToNextSlide() {
    if (_currentPage < slides.length - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _timer?.cancel();
      // Navigate to onboarding after last slide
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      });
    }
  }

  void _onTap() {
    _timer?.cancel(); // Cancel timer to avoid double navigation
    _goToNextSlide();
    if (_currentPage < slides.length - 1) {
      _startAutoSlide(); // Restart timer if not last slide
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onTap,
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(slide.assetPath, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.title,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black45,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              slide.caption,
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Dots Indicator
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? Colors.blueAccent
                              : Colors.white30,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashSlide {
  final String assetPath;
  final String title;
  final String caption;

  const _SplashSlide({
    required this.assetPath,
    required this.title,
    required this.caption,
  });
}
