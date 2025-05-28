import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helper/navigation_helper.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:talentloop/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Use a plain white background.
      body: Container(
        color: AppColors.white,
        child: Column(
          children: [
            // Top section with arc and encouraging speech
            Stack(
              children: [
                ClipPath(
                  clipper: ArcClipper(),
                  child: Container(
                    height: size.height * 0.65,
                    width: double.infinity,
                    color: AppColors.tealShade300, // Use the teal color variable
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Embrace Your Journey with TalentLoop!\n\n'
                              'Ignite your passion, discover your potential, and create a brighter future today!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.delius(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60,),

            // Buttons section with bigger, stylish buttons using coral
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      minimumSize: const Size(double.infinity, 70),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => NavigationHelper.navigateWithScale(context, const LoginScreen()),
                    child: const Text(
                      'Log In',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.coral, width: 2),
                      minimumSize: const Size(double.infinity, 70),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => NavigationHelper.navigateWithScale(context, const RegisterScreen()),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(color: AppColors.coral),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
