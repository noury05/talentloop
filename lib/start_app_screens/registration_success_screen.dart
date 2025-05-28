import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/helper/circle_painter.dart';
import 'package:talentloop/start_app_screens/profile_setup_screen.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  final String fullName;

  const RegistrationSuccessScreen({super.key, required this.fullName});

  @override
  _RegistrationSuccessScreenState createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to UsersScreen after a 3-second delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const ProfileSetupScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CirclePainter(numberOfCircles: 4),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.teal, size: 100),
                const SizedBox(height: 20),
                Text(
                  'Welcome, ${widget.fullName}!',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Registration Successful',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.black54,
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
