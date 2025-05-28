import 'package:flutter/material.dart';
import 'package:talentloop/models/post.dart';
import 'package:talentloop/models/user_skill.dart';
import 'package:talentloop/models/user_model.dart';
import 'package:talentloop/services/api_services.dart';
import '../constants/app_colors.dart';
import '../helper/background_style1.dart';
import '../services/post_services.dart';
import '../services/request_services.dart';
import '../services/skill_services.dart';
import '../widgets/post_card.dart';
import '../models/skill.dart';

class UserScreen extends StatefulWidget {
  final UserModel user;

  const UserScreen({super.key, required this.user});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<UserSkill> skills = [];
  List<Skill> interests = [];
  List<Post> posts = [];
  bool loading = true;
  bool _skillsExpanded = false;
  bool _interestsExpanded = false;
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      skills = await SkillServices.getOtherUserSkills(widget.user.uid);
      interests = await SkillServices.getOtherUserInterests(widget.user.uid);
      posts = await PostServices.getOtherUserPosts(widget.user.uid);
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text(
            'Report User',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildReasonTile('Spam', setState),
                    _buildReasonTile('Inappropriate Content', setState),
                    _buildReasonTile('Harassment', setState),
                    _buildReasonTile('Fake Content', setState),
                    _buildReasonTile('Other', setState),
                  ],
                ),
              );
            },
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedReason != null) {
                  try {
                    await ApiServices.addReport(
                      reportedUserId: widget.user.uid,
                      reason: _selectedReason!,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report submitted successfully.'),
                          backgroundColor: AppColors.teal,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error reporting user: $e');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReasonTile(String reason, void Function(void Function()) setState) {
    return RadioListTile<String>(
      title: Text(reason),
      value: reason,
      groupValue: _selectedReason,
      onChanged: (value) {
        if (!mounted) return;
        setState(() {
          _selectedReason = value;
        });
      },
    );
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
                : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'report') _showReportDialog();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'report',
                            child: Text('Report User'),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
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
                          buildCard: (post) => PostCard(post: post),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                _buildRequestButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final user = widget.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.tealShade200.withOpacity(0.5),
                  backgroundImage: user.imageUrl.isNotEmpty ? NetworkImage(user.imageUrl) : null,
                  child: user.imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 38, color: AppColors.teal)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: user.skillMatched.isEmpty
                            ? Alignment.centerLeft
                            : Alignment.topLeft,
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (user.skillMatched.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Skill Matched: ${user.skillMatched}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (user.bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    user.bio,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        if (user.location.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 6),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  user.location,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
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
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        child: ExpansionTile(
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          onExpansionChanged: (expanded) =>
              mounted?setState(() => _skillsExpanded = expanded):null,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.star, color: AppColors.teal),
          title: const Text('Skills'),
          children: skills.isEmpty
              ? [const ListTile(title: Text('The user has no skills yet.'))]
              : skills.map((skill) {
            final String year = (skill.yearAcquired != null)
                ? skill.yearAcquired.toString()
                : 'Unknown';
            return ListTile(
              title: Text(
                skill.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Chip(
                      label: Text(
                        skill.proficiency,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: AppColors.tealShade200,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          year,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
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
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        child: ExpansionTile(
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          onExpansionChanged: (expanded) =>
              mounted?setState(() => _interestsExpanded = expanded):null,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.favorite, color: AppColors.teal),
          title: const Text('Interests'),
          children: interests.isEmpty
              ? [const ListTile(title: Text('The user has no interests yet.'))]
              : interests
              .map((interest) => ListTile(title: Text(interest.name)))
              .toList(),
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
  }) {
    return Card(
      color: bgColor.withOpacity(0.85),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: AppColors.teal),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          children: items.isEmpty
              ? [const ListTile(title: Text('The user uploaded no posts yet.'))]
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

  Widget _buildRequestButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.softCream,
      child: ElevatedButton(
        onPressed: () async {
          final mySkills = await SkillServices.getOtherUserSkills(widget.user.uid);
          if (!mounted) return;

          String? selectedMySkillId;
          String? selectedOtherSkillId;

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.white,
                    title: const Text(
                      'Make a Request',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Select a skill you want to share:"),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedMySkillId,
                            items: mySkills.map((skill) {
                              return DropdownMenuItem<String>(
                                value: skill.id,
                                child: Text(skill.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (!mounted) return;
                              setState(() {
                                selectedMySkillId = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text("Select a skill you're interested in:"),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedOtherSkillId,
                            items: skills.map((skill) {
                              return DropdownMenuItem<String>(
                                value: skill.id,
                                child: Text(skill.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (!mounted) return;
                              setState(() {
                                selectedOtherSkillId = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedMySkillId != null && selectedOtherSkillId != null) {
                            try {
                              await RequestServices.addRequest(
                                requestedUserId: widget.user.uid,
                                skillId: selectedMySkillId!,
                                interestId: selectedOtherSkillId!,
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Request sent successfully!'),
                                    backgroundColor: AppColors.teal,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to send request: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Submit'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealShade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 4,
        ),
        child: const Text(
          'Make a Request',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

}
