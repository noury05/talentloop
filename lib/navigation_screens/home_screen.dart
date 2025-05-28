import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../helper/background_style1.dart';
import '../services/post_services.dart';
import '../services/user_services.dart';
import '../widgets/post_card.dart';
import '../widgets/user_card.dart';
import '../models/post.dart';
import '../models/user_model.dart';
import 'main_navigation_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  List<UserModel> _suggestedUsers = [];
  List<Post> _suggestedPosts = [];

  @override
  void initState() {

    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _loadData();
  }

  Future<void> _loadData() async {

    final users = await UserServices.getRecommendedUsers();
    final posts = await PostServices.getSuggestedPosts();
    if (!mounted) return;
    setState(() {
      _suggestedUsers = users.take(6).toList();
      _suggestedPosts = posts.take(6).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          BackgroundStyle1(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 30),
                    _buildSectionTitle("Suggested Users", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MainNavigationScreen(initialIndex: 1,)));
                    }),
                    const SizedBox(height: 10),
                    _buildSuggestedUsers(),

                    const SizedBox(height: 30),
                    _buildSectionTitle("Suggested Posts", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MainNavigationScreen(initialIndex: 1,)));
                    }),
                    const SizedBox(height: 10),
                    _buildSuggestedPosts(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Icon(Icons.eco_rounded, color: AppColors.teal, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  "Welcome to TalentLoop!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
                ),
                const SizedBox(height: 2),
                Text(
                  "Exchange your skills, grow together.\nDiscover opportunities that inspire.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Explore Now",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onExpand) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
        ),
        IconButton(
          onPressed: onExpand,
          icon: Icon(Icons.expand_more, color: AppColors.darkTeal),
        ),
      ],
    );
  }

  Widget _buildSuggestedUsers() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedUsers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: UserCard(user: _suggestedUsers[index]),
          );
        },
      ),
    );
  }

  Widget _buildSuggestedPosts() {
    return SizedBox(
      height: 360,
      child: PageView.builder(
        itemCount: _suggestedPosts.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          return PostCard(post: _suggestedPosts[index]);
        },
      ),
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
