import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../helper/background_style1.dart';
import '../helper/navigation_helper.dart';
import '../helper/skeleton_loading.dart';
import '../models/message.dart';
import '../models/skill_exchange.dart';
import '../models/user_model.dart';
import '../screens/user_screen.dart';
import '../services/message_services.dart';
import '../services/user_services.dart';
import '../services/skill_services.dart';
import 'exchange_screen.dart';

class ChatScreen extends StatefulWidget {
  final SkillExchange exchange;
  const ChatScreen({super.key, required this.exchange});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  UserModel? otherUser;
  List<Message> _messages = [];
  Timer? _poller;
  bool _loading = true;
  String skillName = '';
  String interestName = '';

  @override
  void initState() {
    super.initState();
    _loadHeader();
    _startPolling();
  }

  void _startPolling() {
    _refreshMessages();
    _poller = Timer.periodic(const Duration(seconds: 3), (_) => _refreshMessages());
  }

  Future<void> _loadHeader() async {
    otherUser = await UserServices.getOtherUser(widget.exchange.otherUserId);
    final skill = await SkillServices.getSkillById(widget.exchange.yourSkillId);
    final interest = await SkillServices.getSkillById(widget.exchange.otherSkillId);
    skillName = skill.name ?? 'Your Skill';
    interestName = interest.name ?? 'Their Skill';
    if (mounted) setState(() {});
  }

  Future<void> _refreshMessages() async {
    final msgs = await MessageServices.getMessages(widget.exchange.id);

    final me = MessageServices.uid;

    for (var m in msgs) {
      if (m.receiverId == me && m.status != 'read') {
        await MessageServices.updateMessageStatus(m.messageId, 'read');
      }
    }

    if (mounted) {
      setState(() {
        _messages = msgs;
        _loading = false;
      });

      if (_scrollCtrl.hasClients) {
        await Future.delayed(const Duration(milliseconds: 500));
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    _inputController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await MessageServices.sendMessage(
      exchangeId: widget.exchange.id,
      receiverId: widget.exchange.otherUserId,
      message: text,
    );
    await _refreshMessages();
  }

  Widget _buildStatusIcon(Message m) {
    IconData icon;
    Color color;
    switch (m.status) {
      case 'pending':
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case 'sent':
        icon = Icons.check;
        color = Colors.grey;
        break;
      case 'received':
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case 'read':
        icon = Icons.done_all;
        color = AppColors.teal;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }
    return Icon(icon, size: 16, color: color);
  }


  @override
  Widget build(BuildContext context) {
    final me = MessageServices.uid;
    final grouped = <String, List<Message>>{};
    for (var m in _messages) {
      final day = DateFormat.yMMMd().format(m.createdAt as DateTime);
      grouped.putIfAbsent(day, () => []).add(m);
    }

    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AppBar(
              backgroundColor: AppColors.softCream,
              elevation: 0,
              leadingWidth: 36,
              leading: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              title: GestureDetector(
                onTap: () {
                  if (otherUser != null) {
                    NavigationHelper.navigateWithScale(context, UserScreen(user: otherUser!));
                  }
                },
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    if (otherUser != null)
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(otherUser!.imageUrl),
                      )
                    else
                      const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUser?.name ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Exchanging $skillName with $interestName',
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync_alt, color: AppColors.teal, size: 26),
                  onPressed: () {
                    NavigationHelper.navigateWithSlideFromTop(context, ExchangeScreen(exchange: widget.exchange,));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const BackgroundStyle1(),
          Column(
            children: [
              Expanded(
                child: _loading
                    ? ListView.builder(
                  itemCount: 5,
                  itemBuilder: (_, __) => LoadingSkeleton(),
                )
                    : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final day = grouped.keys.elementAt(index);
                    final messagesForDay = grouped[day]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.tealShade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                day,
                                style: const TextStyle(
                                  color: AppColors.darkTeal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...messagesForDay.map((m) {
                          final isMe = m.senderId == me;
                          final isFirstUnread = m.receiverId == me && m.status == 'received' &&
                              !_messages.any((msg) =>
                              msg.createdAt!.isBefore(m.createdAt as DateTime) &&
                                  msg.receiverId == me &&
                                  msg.status == 'received');

                          return Column(
                            children: [
                              if (isFirstUnread)
                                Container(
                                  width: double.infinity,
                                  color: AppColors.teal.withOpacity(0.15),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: const Center(
                                    child: Text(
                                      'You have unread messages',
                                      style: TextStyle(
                                          color: AppColors.darkTeal,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                              Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.tealShade100
                                        : AppColors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                                      bottomRight: Radius.circular(!isMe ? 16 : 0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(m.message, style: const TextStyle(color: Colors.black87)),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormat.Hm().format(m.createdAt as DateTime),
                                            style: const TextStyle(
                                                fontSize: 10, color: Colors.black45),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            _buildStatusIcon(m),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.teal,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
