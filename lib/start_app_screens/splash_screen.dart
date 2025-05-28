import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talentloop/start_app_screens/welcome_screen.dart';
import 'package:talentloop/helper/circle_painter.dart';

import '../helper/navigation_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation constants
  static const _fadeDuration = Duration(milliseconds: 1000);
  static const _initialDelay = Duration(seconds: 2);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(_initialDelay);
    await _controller.forward();
    NavigationHelper.navigateWithFade(context, const WelcomeScreen());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We keep the white background, and the CustomPaint below will add vibrant circles.
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // The custom painter widget draws circles in the background.
          Positioned.fill(
            child: CustomPaint(
              painter: CirclePainter(numberOfCircles: 4),
            ),
          ),
          // Your splash content on top.
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: _buildSplashContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAppLogo(),
        const SizedBox(height: 24),
        _buildAppTitle(),
      ],
    );
  }

  Widget _buildAppLogo() {
    return Hero(
      tag: 'app-logo',
      child: Image.asset(
        'assets/images/logo_splash.png',
        height: 150, // Fixed size for better control
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAppTitle() {
    return Text(
      'TalentLoop',
      style: GoogleFonts.inconsolata(
        fontSize: 42,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 1.8,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }
}
