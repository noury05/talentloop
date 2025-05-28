import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/helper/navigation_helper.dart';
import 'package:talentloop/models/post.dart';
import 'package:talentloop/models/user_model.dart';
import 'package:talentloop/services/api_services.dart';
import '../helper/skeleton_loading.dart';
import '../screens/user_screen.dart';
import '../services/user_services.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  UserModel? _user;
  bool _loading = false;
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final user = await UserServices.getOtherUser(widget.post.userId);
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    } catch (e) {
      if (mounted) print('Error fetching user: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
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
            'Report Post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedReason != null) {
                  try {
                    await ApiServices.addReport(
                      reportedUserId: widget.post.userId,
                      reason: _selectedReason!,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report submitted successfully.'),backgroundColor: AppColors.teal,),
                      );
                    }
                  } catch (e) {
                    print('Error reporting post: $e');
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

  Widget _buildReasonTile(String title, void Function(void Function()) setState) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      value: title,
      groupValue: _selectedReason,
      activeColor: Colors.blue,
      onChanged: (value) =>mounted?
      setState(() => _selectedReason = value):null,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading || _user == null
            ? LoadingSkeleton()
            : Column(  // <-- remove fixed height SizedBox
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildUserInfo()),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.teal),
                  onSelected: (value) {
                    if (value == 'Report') {
                      _showReportDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Report',
                      child: Text('Report'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPostImage(),
            const SizedBox(height: 12),
            _buildPostContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final imageUrl = _user?.imageUrl ?? '';
    ImageProvider<Object>? avatar;
    Widget? fallback;
    if (imageUrl.isEmpty) {
      fallback = const Icon(Icons.person, size: 24, color: AppColors.teal);
    } else if (imageUrl.startsWith('http')) {
      avatar = NetworkImage(imageUrl);
    } else {
      avatar = AssetImage(imageUrl);
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_user != null) {
              NavigationHelper.navigateWithScale(context, UserScreen(user:_user!));
            }
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage: avatar,
            child: fallback,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (_user != null) {
                    NavigationHelper.navigateWithScale(context, UserScreen(user:_user!));
                  }
                },
                child: Text(
                  _user!.name.isNotEmpty ? _user!.name : 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealShade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.post.skillName ?? 'Skill',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostImage() {
    final data = widget.post.imageUrl;
    if (data == null || data.isEmpty) {
      return const SizedBox();
    }

    // If it looks like a URL, just load via network
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          data,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
          errorBuilder: (context, error, stack) => const SizedBox(), // gracefully handle load errors
        ),
      );
    }

    // Otherwise, assume Base64-encoded
    try {
      final bytes = base64Decode(data);
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
        ),
      );
    } catch (e) {
      // Fallback: show placeholder (or network image if you prefer)
      if (mounted) print('Error decoding image: $e');
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://picsum.photos/300/400',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 180,
        ),
      );
    }
  }

  Widget _buildPostContent() {
    return Text(
      widget.post.content,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );
  }
}
