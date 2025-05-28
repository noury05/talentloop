import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BackgroundStyle1 extends StatelessWidget {
  const BackgroundStyle1({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -80, left: -80, child: _buildCircle(200, AppColors.tealShade50)),
        Positioned(bottom: -60, right: -60, child: _buildCircle(180, AppColors.tealShade300.withOpacity(0.15))),
        Positioned(top: MediaQuery.of(context).size.height * 0.35, left: -40, child: _buildCircle(120, AppColors.tealShade100.withOpacity(0.3))),
        Positioned(top: MediaQuery.of(context).size.height * 0.4, right: -40, child: _buildCircle(100, AppColors.tealShade200.withOpacity(0.2))),
      ],
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
