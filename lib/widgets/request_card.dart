import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../helper/skeleton_loading.dart';
import '../models/skill.dart';
import '../models/user_model.dart';
import '../models/exchange_request.dart';
import '../services/skill_services.dart';
import '../services/user_services.dart';
import '../services/request_services.dart';

class RequestCard extends StatefulWidget {
  final ExchangeRequest request;
  final VoidCallback onRequestUpdated;

  const RequestCard({
    Key? key,
    required this.request,
    required this.onRequestUpdated,
  }) : super(key: key);

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _combinedFuture = Future.wait([
      UserServices.getOtherUser(widget.request.requesterId),
      SkillServices.getSkillById(widget.request.skillId),
      SkillServices.getSkillById(widget.request.interestId),
    ]);
  }

  Future<void> _updateRequestStatus(String newStatus) async {
    try {
      await RequestServices.updateRequestStatus(newStatus,widget.request);
      widget.onRequestUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.request.status.toLowerCase() != 'pending') {
      return const SizedBox.shrink(); // Don't show non-pending requests
    }

    return FutureBuilder<List<dynamic>>(
      future: _combinedFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingSkeleton();
        }

        final UserModel user = snapshot.data![0];
        final Skill skill = snapshot.data![1];
        final Skill interest = snapshot.data![2];
        final bool hasImage = user.imageUrl != null && user.imageUrl!.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tealShade50.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tealShade200),
            boxShadow: [
              BoxShadow(
                color: AppColors.tealShade100.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.teal,
                backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
                child: hasImage ? null : const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const TextSpan(
                            text: ' with ',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          TextSpan(
                            text: interest.name,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () => _updateRequestStatus('rejected'),
                            icon: const Icon(Icons.close, color: Colors.brown),
                            label: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.brown),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _updateRequestStatus('accepted'),
                            icon: const Icon(Icons.check),
                            label: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        );
      },
    );
  }
}
