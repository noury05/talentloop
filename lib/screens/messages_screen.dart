// lib/screens/messages_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../helper/background_style1.dart';
import '../models/skill_exchange.dart';
import '../services/skill_services.dart';
import '../widgets/chat_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SkillExchange> _exchanges = [];
  bool _isLoading = true;

  late final String _uid;
  late final DatabaseReference _exchangesRef;
  StreamSubscription<DatabaseEvent>? _childAddedSub;
  StreamSubscription<DatabaseEvent>? _childChangedSub;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _exchangesRef = FirebaseDatabase.instance.ref('user_exchanges/$_uid');
    _listenToExchangeChanges();
    _fetchExchanges();
  }

  void _listenToExchangeChanges() {
    // when an exchange is added or updated, re-fetch
    _childAddedSub = _exchangesRef.onChildAdded.listen((_) => _fetchExchanges());
    _childChangedSub = _exchangesRef.onChildChanged.listen((_) => _fetchExchanges());
  }

  Future<void> _fetchExchanges() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final fetched = await SkillServices.getUserExchanges();
      if (!mounted) return;
      setState(() {
        _exchanges = fetched;
      });
    } catch (e) {
      // ignore or show error snackbar
      print('Error fetching exchanges: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _childAddedSub?.cancel();
    _childChangedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          const BackgroundStyle1(),
          Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search conversations...",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Messages",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              // list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                    : _exchanges.isEmpty
                    ? const Center(
                  child: Text(
                    "No exchanges found.",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _exchanges.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade300,
                    indent: 12,
                    endIndent: 12,
                    thickness: 0.6,
                  ),
                  itemBuilder: (context, index) {
                    return ChatCard(exchange: _exchanges[index]);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
