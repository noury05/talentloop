import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talentloop/screens/user_screen.dart';
import '../constants/app_colors.dart';
import '../helper/background_style1.dart';
import '../models/skill_exchange.dart';
import '../models/session.dart';
import '../models/user_model.dart';
import '../screens/chat_screen.dart';
import '../services/session_services.dart';
import '../services/skill_services.dart';
import '../services/user_services.dart';
import '../widgets/session_card.dart';

class ExchangeScreen extends StatefulWidget {
  final SkillExchange exchange;
  const ExchangeScreen({Key? key, required this.exchange}) : super(key: key);

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  bool _showSessionForm = false;
  bool _showReviewForm = false;
  DateTime? _selectedDate;
  int? _rating;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _sessionsNeededController = TextEditingController();
  UserModel? _otherUser;
  String _yourSkillName = '';
  String _theirSkillName = '';
  Timer? _poller;
  List<Session> _sessions = [];
  bool _loadingSessions = true;

  bool get isOngoing => widget.exchange.status == 'ongoing';
  bool get isDropped => widget.exchange.status == 'dropped';
  bool get isCompleted => widget.exchange.status == 'completed';

  int get sessionsDone => widget.exchange.sessionsDone;
  int get sessionsNeeded => widget.exchange.sessionNeeded;

  double get progress => sessionsNeeded > 0 ? sessionsDone / sessionsNeeded : 0;

  @override
  void initState() {
    super.initState();
    _loadHeaderData();
    _pollSessions();
  }

  @override
  void dispose() {
    _poller?.cancel();
    _commentController.dispose();
    _sessionsNeededController.dispose();
    super.dispose();
  }

  void _pollSessions() {
    _refreshSessions();
    _poller = Timer.periodic(const Duration(seconds: 5), (_) => _refreshSessions());
  }

  Future<void> _refreshSessions() async {
    final sessions = await SessionServices.getSessions(widget.exchange.id);
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loadingSessions = false;
    });
  }

  Future<void> _loadHeaderData() async {
    final other = await UserServices.getOtherUser(widget.exchange.otherUserId);
    final yours = await SkillServices.getSkillById(widget.exchange.yourSkillId);
    final theirs = await SkillServices.getSkillById(widget.exchange.otherSkillId);
    if (!mounted) return;
    setState(() {
      _otherUser = other;
      _yourSkillName = yours?.name ?? '';
      _theirSkillName = theirs?.name ?? '';
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitSession() async {
    if (_selectedDate == null) return;
    await SessionServices.scheduleSession(
      exchangeId: widget.exchange.id,
      count: sessionsDone + 1,
      timeScheduled: _selectedDate!,
    );
    if (!mounted) return;
    setState(() {
      widget.exchange.sessionsDone += 1;
      _showSessionForm = false;
      _selectedDate = null;
    });
    _refreshSessions();
  }

  Future<void> _updateSessionsNeeded() async {
    final newValue = int.tryParse(_sessionsNeededController.text);
    if (newValue != null && newValue > 0) {
      await SkillServices.updateSessionsNeeded(
        exchangeId: widget.exchange.id,
        sessionsNeeded: newValue,
      );
      if (!mounted) return;
      setState(() => widget.exchange.sessionNeeded = newValue);
    }
  }

  void _submitReview() {
    print('Review submitted: rating=$_rating comment=${_commentController.text}');
    if (!mounted) return;
    setState(() => _showReviewForm = false);
  }

  Color _getStatusColor() {
    switch (widget.exchange.status) {
      case 'ongoing':
        return AppColors.teal;
      case 'completed':
        return AppColors.coral;
      case 'dropped':
        return Colors.grey;
      default:
        return AppColors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          const BackgroundStyle1(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.darkTeal),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Exchange Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: AppColors.darkTeal),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatScreen(exchange: widget.exchange)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _otherUser != null
                                ? Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => UserScreen(user: _otherUser!)),
                            )
                                : null,
                            child: CircleAvatar(
                              radius: 36,
                              backgroundImage: _otherUser != null
                                  ? NetworkImage(_otherUser!.imageUrl)
                                  : null,
                              backgroundColor: AppColors.tealShade50,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _otherUser?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkTeal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _otherUser?.location ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.tealShade300,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _otherUser?.bio ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.tealShade300,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text('You: $_yourSkillName'),
                            backgroundColor: AppColors.tealShade50,
                          ),
                          Chip(
                            label: Text('Them: $_theirSkillName'),
                            backgroundColor: AppColors.tealShade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Chip(
                          label: Text(widget.exchange.status.toUpperCase()),
                          backgroundColor: _getStatusColor().withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sessions Needed Input
                  if (sessionsNeeded == 0)
                    Column(
                      children: [
                        TextField(
                          controller: _sessionsNeededController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter number of sessions needed',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.tealShade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _updateSessionsNeeded,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coral,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Submit Sessions Needed'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sessions Needed: $sessionsNeeded',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: AppColors.tealShade50,
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$sessionsDone of $sessionsNeeded sessions completed',
                          style: TextStyle(
                            color: AppColors.tealShade300,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Scheduled Sessions List
                  const Text(
                    'Scheduled Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _loadingSessions
                      ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                      : _sessions.isEmpty
                      ? Text(
                    'No upcoming sessions',
                    style: TextStyle(color: AppColors.tealShade300),
                  )
                      : Column(
                    children: _sessions.map((s) => SessionCard(session: s)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Schedule New Session
                  if (!isCompleted && sessionsNeeded > 0)
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Schedule New Session',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTeal,
                            ),
                          ),
                          trailing: Icon(
                            _showSessionForm ? Icons.expand_less : Icons.expand_more,
                            color: AppColors.darkTeal,
                          ),
                          onTap: () => setState(() => _showSessionForm = !_showSessionForm),
                        ),
                        if (_showSessionForm)
                          Column(
                            children: [
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_today, color: AppColors.teal),
                                label: Text(
                                  _selectedDate == null
                                      ? 'Choose date'
                                      : dateFmt.format(_selectedDate!),
                                  style: const TextStyle(color: AppColors.teal),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _selectedDate != null ? _submitSession : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.coral,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Schedule Session'),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                      ],
                    ),

                  // Review Section
                  Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Leave a Review',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        trailing: Icon(
                          _showReviewForm ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.darkTeal,
                        ),
                        onTap: () => setState(() => _showReviewForm = !_showReviewForm),
                      ),
                      if (_showReviewForm)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    _rating != null && index < _rating!
                                        ? Icons.star
                                        : Icons.star_outline,
                                    color: AppColors.coral,
                                    size: 32,
                                  ),
                                  onPressed: () => setState(() => _rating = index + 1),
                                );
                              }),
                            ),
                            TextField(
                              controller: _commentController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Share your experience...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.tealShade50,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _rating != null ? _submitReview : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.coral,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Submit Review'),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                    ],
                  ),

                  // Drop Button
                  if (!isCompleted)
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ElevatedButton(
                        onPressed: _confirmDropExchange,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                          child: Text(
                            isDropped ? 'Continue Exchange' : 'Drop Exchange',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _confirmDropExchange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This will drop the exchange and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SkillServices.dropExchange(widget.exchange.id);
              if (!mounted) return;
              setState(() {
                widget.exchange.status = 'dropped';
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}