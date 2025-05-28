import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/models/post.dart';
import 'package:talentloop/models/user_model.dart';
import '../helper/skeleton_loading.dart';
import '../services/post_services.dart';
import '../services/user_services.dart';

class UserPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onDelete;
  final ValueChanged<Post>? onUpdate;

  const UserPostCard({
    Key? key,
    required this.post,
    this.onDelete,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<UserPostCard> createState() => _UserPostCardState();
}

class _UserPostCardState extends State<UserPostCard> {
  UserModel? _user;
  bool _loading = false;
  bool _actionLoading = false;

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
      setState(() => _user = user);
    } catch (e) {
      if (mounted) print('Error fetching user: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deletePost() async {
    if (!mounted) return;
    setState(() => _actionLoading = true);
    try {
      await PostServices.deletePost(widget.post.postId);
      if (mounted) {
        widget.onDelete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _toggleStatus() async {
    if (!mounted) return;
    setState(() => _actionLoading = true);
    final newStatus = widget.post.status == 'active' ? 'inactive' : 'active';
    try {
      await PostServices.updatePost(widget.post.postId, {'status': newStatus});
      if (!mounted) return;
      setState(() {
        widget.post.status = newStatus;
      });
      widget.onUpdate?.call(widget.post);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post ${newStatus == 'active' ? 'activated' : 'inactivated'}'),backgroundColor: Colors.teal,),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status'),backgroundColor: Colors.teal,),

        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
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
            : SizedBox(
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with user info and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildUserInfo()),
                  _actionLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.coral,
                    ),
                  )
                      : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black54),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deletePost();
                      } else if (value == 'toggle') {
                        _toggleStatus();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(widget.post.status == 'active'
                            ? 'Inactivate'
                            : 'Activate'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPostImage(),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildPostContent(),
                ),
              ),
            ],
          ),
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
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.white,
          backgroundImage: avatar,
          child: fallback,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user!.name.isNotEmpty ? _user!.name : 'Unknown User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
