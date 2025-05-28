import 'package:flutter/material.dart';
import 'package:talentloop/helper/skeleton_loading.dart';
import 'package:talentloop/models/skill_exchange.dart';
import 'package:talentloop/models/user_model.dart';
import 'package:talentloop/models/skill.dart';
import 'package:talentloop/services/skill_services.dart';
import 'package:talentloop/services/user_services.dart';
import 'package:talentloop/constants/app_colors.dart';
import '../screens/user_screen.dart';
import '../screens/exchange_screen.dart';

class SkillExchangeCard extends StatefulWidget {
  final SkillExchange exchange;

  const SkillExchangeCard({Key? key, required this.exchange}) : super(key: key);

  @override
  _SkillExchangeCardState createState() => _SkillExchangeCardState();
}

class _SkillExchangeCardState extends State<SkillExchangeCard> {
  UserModel? _otherUser;
  Skill? _otherSkill;
  Skill? _yourSkill;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final otherUser = await UserServices.getOtherUser(widget.exchange.otherUserId);
      final otherSkill = await SkillServices.getSkillById(widget.exchange.otherSkillId);
      final yourSkill = await SkillServices.getSkillById(widget.exchange.yourSkillId);
      if (!mounted) return;
      setState(() {
        _otherUser = otherUser;
        _otherSkill = otherSkill;
        _yourSkill = yourSkill;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child:_loading
            ? LoadingSkeleton()
            : IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar, name, and detail icon
              Row(
                children: [
                  GestureDetector(
                    onTap: _navigateToUserProfile,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.tealShade300,
                      backgroundImage: (_otherUser?.imageUrl.isNotEmpty ?? false)
                          ? NetworkImage(_otherUser!.imageUrl)
                          : null,
                      child: (_otherUser?.imageUrl.isEmpty ?? true)
                          ? Icon(Icons.person, size: 28, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _navigateToUserProfile,
                      child: Text(
                        _otherUser?.name ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.teal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.teal),
                    tooltip: 'Exchange Details',
                    onPressed: _navigateToExchangeScreen,
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Skills
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "They offer: ${_otherSkill?.name ?? widget.exchange.otherSkillId}",
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check, size: 16, color: AppColors.coral),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "You offer: ${_yourSkill?.name ?? widget.exchange.yourSkillId}",
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status and session count
              Row(
                children: [
                  Chip(
                    label: Text(
                      widget.exchange.status.toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColors.tealShade100,
                    labelStyle: TextStyle(color: AppColors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Sessions: ${widget.exchange.sessionNeeded}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserProfile() {
    if (_otherUser == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserScreen(user: _otherUser!)),
    );
  }

  void _navigateToExchangeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExchangeScreen(exchange: widget.exchange,)),
    );
  }
}
