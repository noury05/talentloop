import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/navigation_screens/search_screen.dart';
import 'package:talentloop/navigation_screens/user_profile_screen.dart';
import 'exchanges_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({Key? key, this.initialIndex = 0})
      : assert(initialIndex >= 0 && initialIndex <= 3, 'initialIndex must be between 0 and 3'),
        super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    ExchangesScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: Colors.white,
        activeColor: AppColors.tealShade300,
        color: Colors.grey.shade600,
        items: const [
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.search),
          TabItem(icon: Icons.compare_arrows),
          TabItem(icon: Icons.person),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (int index) {
          if (!mounted) return;
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

