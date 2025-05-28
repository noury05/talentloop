import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/post_services.dart';
import '../services/skill_services.dart';
import '../services/user_services.dart';
import '../widgets/user_post_card.dart';
import '../start_app_screens/login_screen.dart';
import 'package:talentloop/models/skill_exchange.dart';
import 'package:talentloop/models/post.dart';
import 'package:talentloop/models/skill.dart';
import 'package:talentloop/models/user_model.dart';
import 'package:talentloop/models/user_skill.dart';
import 'package:talentloop/screens/skill_selection.dart';
import '../constants/app_colors.dart';
import '../helper/background_style1.dart';
import '../helper/navigation_helper.dart';
import '../widgets/skill_exchange_card.dart';
import '../screens/add_post_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/interest_selection.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserModel? user;
  List<UserSkill> skills = [];
  List<Skill> interests = [];
  List<Post> posts = [];
  List<SkillExchange> exchanges = [];
  bool loading = true;
  bool _skillsExpanded = false;
  bool _interestsExpanded = false;
  bool _postsExpanded = false;
  bool _exchangesExpanded = false;
  bool _feedbackExpanded = false;

  // Feedback form controllers
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      user = await UserServices.getThisUser();
      skills = await SkillServices.getUserSkills();
      interests = await SkillServices.getUserInterests();
      posts = await PostServices.getUserPosts();
      exchanges = await SkillServices.getUserExchanges();
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _deleteSkill(UserSkill skill) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Are you sure you want to delete this skill?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(child: const Text('Delete'), onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed == true) {
      await SkillServices.deleteUserSkill(skill.id);
      if (!mounted) return;
      setState(() => skills.remove(skill));
    }
  }

  Future<void> _deleteInterest(Skill interest) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Are you sure you want to delete this interest?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(child: const Text('Delete'), onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed == true) {
      await SkillServices.deleteUserInterest(interest.id);
      if (!mounted) return;
      setState(() => interests.remove(interest));
    }
  }

  void _onPostDeleted(String postId) {
    if (!mounted) return;
    setState(() {
      posts.removeWhere((post) => post.postId == postId);
    });
  }

  void _onPostUpdated(Post updatedPost) {
    if (!mounted) return;
    setState(() {
      int index = posts.indexWhere((post) => post.postId == updatedPost.postId);
      if (index != -1) posts[index] = updatedPost;
    });
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0 || _feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and feedback.')),
      );
      return;
    }

    try {
      final feedbackData = {
        'rating': _rating,
        'feedback': _feedbackController.text.trim(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? '',
      };

      //p

      if (!mounted) return;
      setState(() {
        _rating = 0;
        _feedbackController.clear();
        _feedbackExpanded = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    } catch (e) {
      print('Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit feedback.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          const BackgroundStyle1(),
          SafeArea(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.coral))
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAvatarSection(),
                  const SizedBox(height: 28),
                  _buildSkillsSection(),
                  _buildInterestsSection(),
                  _buildCarouselSection<Post>(
                    title: 'Posts',
                    icon: Icons.article,
                    items: posts,
                    height: 340,
                    bgColor: Colors.amber.shade100,
                    buildCard: (post) => UserPostCard(
                      post: post,
                      onDelete: () => _onPostDeleted(post.postId),
                      onUpdate: (updatedPost) => _onPostUpdated(updatedPost),
                    ),
                    onAddPressed: () => NavigationHelper.navigateWithSlideFromRight(
                      context, const AddPostScreen(),
                    ),
                    isExpanded: _postsExpanded,
                    onExpansionChanged: (expanded) => mounted ? setState(() => _postsExpanded = expanded):null,
                  ),
                  _buildCarouselSection<SkillExchange>(
                    title: 'Skill Exchanges',
                    icon: Icons.swap_horiz,
                    items: exchanges,
                    height: 200,
                    bgColor: AppColors.tealShade100,
                    buildCard: (ex) => SkillExchangeCard(exchange: ex),
                    isExpanded: _exchangesExpanded,
                    onExpansionChanged: (expanded) => mounted?setState(() => _exchangesExpanded = expanded):null,
                  ),
                  Card(
                    color: Colors.orange.shade50.withOpacity(0.85),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: Colors.black,
                        collapsedIconColor: Colors.black,
                        initiallyExpanded: _feedbackExpanded,
                        onExpansionChanged: (expanded) {
                          if (!mounted) return;
                          setState(() => _feedbackExpanded = expanded);
                        },
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: const Icon(Icons.feedback, color: AppColors.teal),
                        title: const Text('Leave Feedback'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rate the app:'),
                                Row(
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      icon: Icon(
                                        index < _rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                      ),
                                      onPressed: () => setState(() => _rating = index + 1),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                const Text('Your feedback:'),
                                TextField(
                                  controller: _feedbackController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: 'Write your thoughts here...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: _submitFeedback,
                                    icon: const Icon(Icons.send),
                                    label: const Text('Submit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.teal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const LoginScreen(),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(opacity: animation, child: child),
                          ),
                              (route) => false,
                        );
                      },
                      child: const Text('Logout', style: TextStyle(
                        color: AppColors.teal, fontSize: 16, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.tealShade200,
              backgroundImage: (user?.imageUrl.isNotEmpty ?? false)
                  ? NetworkImage(user!.imageUrl)
                  : null,
              child: (user?.imageUrl.isEmpty ?? true)
                  ? const Icon(Icons.person, size: 45, color: AppColors.teal)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                user?.name ?? 'No Name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if ((user?.bio ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 8),
            child: Text(
              user!.bio,
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.left,
            ),
          ),
        if ((user?.location ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(user!.location, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => NavigationHelper.navigateWithSlideFromLeft(
              context, const EditProfileScreen(),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSkillsSection() {
    return Card(
      color: Colors.lightBlue.shade100.withOpacity(0.85),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          onExpansionChanged: (expanded) => mounted?setState(() => _skillsExpanded = expanded):null,
          initiallyExpanded: _skillsExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.star, color: AppColors.teal),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Skills'),
              if (_skillsExpanded)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () => NavigationHelper.navigateWithSlideFromRight(
                    context, const SkillSelection(),
                  ),
                ),
            ],
          ),
          children: skills.map((skill) {
            return ListTile(
              title: Text(skill.name),
              subtitle: Text('${skill.proficiency} • ${skill.yearAcquired}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: () => _deleteSkill(skill),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Card(
      color: Colors.pink.shade100.withOpacity(0.85),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          onExpansionChanged: (expanded) => mounted?setState(() => _interestsExpanded = expanded):null,
          initiallyExpanded: _interestsExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.favorite, color: AppColors.teal),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Interests'),
              if (_interestsExpanded)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () => NavigationHelper.navigateWithSlideFromRight(
                    context, const InterestSelection(),
                  ),
                ),
            ],
          ),
          children: interests.map((interest) {
            return ListTile(
              title: Text(interest.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: () => _deleteInterest(interest),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCarouselSection<T>({
    required String title,
    required IconData icon,
    required List<T> items,
    required double height,
    required Color bgColor,
    required Widget Function(T) buildCard,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    VoidCallback? onAddPressed,
  }) {
    return Card(
      color: bgColor.withOpacity(0.85),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: AppColors.teal),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              if (isExpanded && onAddPressed != null)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: onAddPressed,
                ),
            ],
          ),
          children: items.isEmpty
              ? [const ListTile(title: Text('No data available'))]
              : [
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: items.length,
                itemBuilder: (context, index) => buildCard(items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
