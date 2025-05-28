import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../helper/skeleton_loading.dart';
import '../models/skill.dart';
import '../models/exchange_request.dart';
import '../models/user_model.dart';
import '../services/skill_services.dart';
import '../services/user_services.dart';
import '../services/request_services.dart';

class MyRequestCard extends StatefulWidget {
  final ExchangeRequest request;
  final VoidCallback onRequestDeleted;

  const MyRequestCard({
    super.key,
    required this.request,
    required this.onRequestDeleted,
  });

  @override
  State<MyRequestCard> createState() => _MyRequestCardState();
}

class _MyRequestCardState extends State<MyRequestCard> {
  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _combinedFuture = Future.wait([
      UserServices.getOtherUser(widget.request.requestedUserId),
      SkillServices.getSkillById(widget.request.skillId),
      SkillServices.getSkillById(widget.request.interestId),
    ]);
  }

  Future<void> _handleDelete() async {
    try {
      await RequestServices.deleteRequest(widget.request.id);
      widget.onRequestDeleted(); // Refresh parent
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete request: $e')),
      );
    }
  }

  Widget _buildActionButton() {
    switch (widget.request.status.toLowerCase()) {
      case 'pending':
        return OutlinedButton.icon(
          onPressed: _handleDelete,
          icon: const Icon(Icons.cancel, color: Colors.brown),
          label: const Text('Cancel', style: TextStyle(color: Colors.brown)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.brown),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      case 'rejected':
        return TextButton.icon(
          onPressed: _handleDelete,
          icon: const Icon(Icons.delete_forever, color: Colors.grey),
          label: const Text('Remove', style: TextStyle(color: Colors.grey)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      case 'accepted':
        return ElevatedButton.icon(
          onPressed: () {
            // Add navigation to chat if needed
          },
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Start Chatting'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _combinedFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingSkeleton();
        }

        final UserModel user = snapshot.data![0];
        final Skill skill = snapshot.data![1];
        final Skill interest = snapshot.data![2];
        final bool hasImage = user.imageUrl.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.tealShade50.withOpacity(0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.tealShade200),
            boxShadow: [
              BoxShadow(
                color: AppColors.tealShade100.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.teal,
                    backgroundImage: hasImage ? NetworkImage(user.imageUrl) : null,
                    child: hasImage
                        ? null
                        : const Icon(Icons.swap_horiz, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Exchanging ',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              TextSpan(
                                text: skill.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: ' with ',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              TextSpan(
                                text: interest.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: _buildActionButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}
