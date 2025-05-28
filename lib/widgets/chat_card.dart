import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../helper/navigation_helper.dart';
import '../helper/skeleton_loading.dart';
import '../models/message.dart';
import '../models/skill_exchange.dart';
import '../models/user_model.dart';
import '../screens/chat_screen.dart';
import '../services/message_services.dart';
import '../services/user_services.dart';

class ChatCard extends StatefulWidget {
  final SkillExchange exchange;

  const ChatCard({super.key, required this.exchange});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();
  UserModel? otherUser;
  String? lastMessage;
  String? lastMessageDate;
  String? lastSenderId;
  String? lastStatus;
  int unreadCount = 0;
  bool loading = true;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadChatInfo();
    _listenToMessages();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChatInfo() async {
    final otherUserId = widget.exchange.otherUserId;
    try {
      final results = await Future.wait([
        UserServices.getOtherUser(otherUserId),
        MessageServices.getLastMessage(widget.exchange.id),
        MessageServices.getUnreadReceivedMessageCount(widget.exchange.id),
      ]);

      final fetchedUser = results[0] as UserModel;
      final fetchedLastMessage = results[1] as Message;
      final fetchedUnreadCount = results[2] as int;
      if (!mounted) return;
      setState(() {
        otherUser = fetchedUser;
        lastMessage = fetchedLastMessage.message;
        lastSenderId = fetchedLastMessage.senderId;
        lastStatus = fetchedLastMessage.status;
        if (fetchedLastMessage.createdAt != null) {
          lastMessageDate = DateFormat('MMM d, h:mm a').format(fetchedLastMessage.createdAt as DateTime );
        }
        unreadCount = fetchedUnreadCount;
        loading = false;
      });
    } catch (e) {
      print('Error loading chat info: $e');
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  void _listenToMessages() {
    final messagesRef = _db.child('messages/${widget.exchange.id}');
    _messageSubscription = messagesRef.onChildAdded.listen((event) async {
      await _loadChatInfo();
    });
  }

  Widget _buildStatusIcon() {
    if (_auth.currentUser?.uid != lastSenderId) return const SizedBox();

    IconData icon;
    Color color;

    switch (lastStatus) {
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
        icon = Icons.access_time;
        color = Colors.grey.shade400;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(icon, size: 16, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      LoadingSkeleton();
    }

    if (otherUser == null) return const SizedBox();

    return GestureDetector(
      onTap: () {
        NavigationHelper.navigateWithFade(context, ChatScreen(exchange: widget.exchange,));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(otherUser?.imageUrl ?? ''),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUser?.name ?? 'Unknown',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (lastMessage != null) _buildStatusIcon(),
                            Expanded(
                              child: Text(
                                lastMessage?.isNotEmpty == true
                                    ? lastMessage!
                                    : "Say hi and start chatting!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: lastMessage?.isNotEmpty == true
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.grey,
                                  fontStyle: lastMessage?.isNotEmpty == true
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (lastMessageDate != null && lastMessage?.isNotEmpty == true) ...[
                              const SizedBox(width: 6),
                              Text(
                                lastMessageDate!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 10,
                bottom: 22,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

