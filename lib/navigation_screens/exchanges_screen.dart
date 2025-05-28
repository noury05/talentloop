import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talentloop/screens/messages_screen.dart';
import '../constants/app_colors.dart';
import '../helper/navigation_helper.dart';
import '../services/message_services.dart';
import '../services/request_services.dart';
import '../widgets/my_request_card.dart';
import '../helper/background_style1.dart';
import '../models/exchange_request.dart';
import '../widgets/request_card.dart';

class ExchangesScreen extends StatefulWidget {
  const ExchangesScreen({super.key});

  @override
  State<ExchangesScreen> createState() => _ExchangesScreenState();
}

class _ExchangesScreenState extends State<ExchangesScreen> {
  int _selectedIndex = 0;
  late Future<List<ExchangeRequest>> _futureRequests;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _loadUnreadMessageCount(); // <-- NEW
  }

  void _loadUnreadMessageCount() async {
    try {
      // Replace with actual exchange ID if needed, or loop if multiple
      const dummyExchangeId = 'exchangeId1'; // Use appropriate exchange ID logic
      final count = await MessageServices.getUnreadReceivedMessageCount(dummyExchangeId);
      if (mounted) {
        setState(() {
          _unreadMessageCount = count;
        });
      }
    } catch (e) {
      debugPrint('Failed to load unread message count: $e');
    }
  }

  void _loadRequests() {
    if (!mounted) return;
    setState(() {
      _futureRequests = _selectedIndex == 0
          ? RequestServices.getRequestsToMe()
          : RequestServices.getMyExchangeRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          const BackgroundStyle1(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.messageCircle, size: 24),
                            onPressed: () => NavigationHelper.navigateWithSlideFromRight(context, MessagesScreen()),
                          ),
                          if (_unreadMessageCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                child: Center(
                                  child: Text(
                                    _unreadMessageCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!mounted) return;
                            setState(() => _selectedIndex = 0);
                            _loadRequests();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedIndex == 0
                                  ? AppColors.teal
                                  : AppColors.tealShade100,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _selectedIndex == 0
                                  ? [
                                BoxShadow(
                                  color: AppColors.teal.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Requests to Me",
                              style: TextStyle(
                                color: _selectedIndex == 0
                                    ? Colors.white
                                    : AppColors.darkTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!mounted) return;
                            setState(() => _selectedIndex = 1);
                            _loadRequests();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedIndex == 1
                                  ? AppColors.teal
                                  : AppColors.tealShade100,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _selectedIndex == 1
                                  ? [
                                BoxShadow(
                                  color: AppColors.coral.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "My Requests",
                              style: TextStyle(
                                color: _selectedIndex == 1
                                    ? Colors.white
                                    : AppColors.darkTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: FutureBuilder<List<ExchangeRequest>>(
                    future: _futureRequests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.teal),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No exchange requests found."));
                      }

                      final requests = snapshot.data!;
                      final hasPending = requests.any(
                            (r) => r.status.toLowerCase() == 'pending',
                      );

                      if (!hasPending && _selectedIndex == 0) {
                        return const Center(child: Text("No new requests at the moment."));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _selectedIndex == 0
                                ? RequestCard( // "Requests to Me"
                              request: request,
                              onRequestUpdated: _loadRequests,
                            )
                                : MyRequestCard( // "My Requests"
                              request: request,
                              onRequestDeleted: _loadRequests,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
