import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/post_services.dart';
import '../services/skill_services.dart';
import '../widgets/post_card.dart';
import '../widgets/user_card.dart';
import '../helper/background_style1.dart';
import '../models/post.dart';
import '../models/skill.dart';
import '../models/user_model.dart';
import '../models/search_result.dart';
import '../services/api_services.dart';

enum SearchMode { posts, users }

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // — your original fields —
  List<Skill> _skillOptions = [Skill(id: 'All', name: 'All')];
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  String _searchQuery = '';
  Skill _selectedSkill = Skill(id: 'All', name: 'All');
  bool _loading = true;

  // — new for “search mode” —
  bool _searched = false;
  SearchMode _mode = SearchMode.posts;
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final interests = await SkillServices.getUserInterests();
      if (!mounted) return;
      setState(() {
        _skillOptions = [Skill(id: 'All', name: 'All'), ...interests];
      });
      await _fetchPosts();
    } catch (e) {
      debugPrint("Error initializing data: $e");
    }
  }

  Future<void> _fetchPosts() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final fetched = _selectedSkill.id == 'All'
          ? await PostServices.getSuggestedPosts()
          : await PostServices.getPostsBySkill(_selectedSkill.id);
      if (!mounted) return;
      setState(() {
        _posts = fetched;
        _applyPostFilter();
      });
    } catch (e) {
      debugPrint("Error fetching posts: $e");
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _applyPostFilter() {
    if (_searchQuery.isEmpty && !_searched) {
      _filteredPosts = List.from(_posts);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredPosts = _posts.where((p) =>
      p.skillName.toLowerCase().contains(q) ||
          p.content.toLowerCase().contains(q)
      ).toList();
    }
  }

  void _onSearchChanged(String q) {
    if (!mounted) return;
    setState(() {
      _searchQuery = q;
      if (!_searched) _applyPostFilter();
      else if (_mode == SearchMode.posts) _applyPostFilter();
      else {
        final qq = q.toLowerCase();
        _filteredUsers = _users.where((u) =>
        u.name.toLowerCase().contains(qq) ||
            u.email.toLowerCase().contains(qq)
        ).toList();
      }
    });
  }

  Future<void> _onSearchPressed() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _searched = true;
      _searchQuery = q;
    });
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final result = await ApiServices.search(q);
      if (!mounted) return;
      setState(() {
        _posts = result.posts;
        _users = result.users;
        _mode = SearchMode.posts;
        _applyPostFilter();
      });
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    if (!mounted) return;
    setState(() {
      _searched = false;
      _searchQuery = '';
      _filteredPosts.clear();
      _filteredUsers.clear();
      _mode = SearchMode.posts;
      _applyPostFilter();
    });
  }

  void _onSkillSelected(Skill skill) {
    if (!mounted) return;
    setState(() => _selectedSkill = skill);
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          const BackgroundStyle1(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ——— SEARCH ROW ———
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search posts, users…',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // coral search icon
                      Material(
                        color: AppColors.coral,
                        shape: const CircleBorder(),
                        elevation: 4,
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: _onSearchPressed,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // clear filter icon
                      if (_searched)
                        Material(
                          color: AppColors.darkTeal,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: _clearSearch,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ——— MODE CHOICES ———
                  if (_searched)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Posts'),
                          selected: _mode == SearchMode.posts,
                          onSelected: (_) => mounted?setState(() => _mode = SearchMode.posts):null,
                          selectedColor: AppColors.coral,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Users'),
                          selected: _mode == SearchMode.users,
                          onSelected: (_) => mounted?setState(() => _mode = SearchMode.users):null,
                          selectedColor: AppColors.coral,
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // ——— CONDITIONAL CONTENT ———
                  if (!_searched) ...[
                    // your original skill chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _skillOptions.map((skill) {
                          final selected = skill.id == _selectedSkill.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(skill.name,
                                  style: TextStyle(
                                    color: selected ? Colors.white : Colors.black87,
                                  )),
                              selected: selected,
                              onSelected: (_) => _onSkillSelected(skill),
                              selectedColor: AppColors.coral,
                              backgroundColor: Colors.white,
                              elevation: 2,
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // your original posts list
                    _loading
                        ? const Center(
                        child: CircularProgressIndicator(color: AppColors.darkTeal))
                        : _filteredPosts.isEmpty
                        ? const Center(child: Text("No posts found."))
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredPosts.length,
                      itemBuilder: (ctx, i) => PostCard(post: _filteredPosts[i]),
                    ),
                  ] else ...[
                    // search results
                    if (_loading)
                      const Center(
                          child: CircularProgressIndicator(color: AppColors.darkTeal))
                    else if (_mode == SearchMode.posts)
                      _buildPostResults()
                    else
                      _buildUserResults(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostResults() {
    if (_filteredPosts.isEmpty) return const Center(child: Text("No posts found."));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPosts.length,
      itemBuilder: (_, i) => PostCard(post: _filteredPosts[i]),
    );
  }

  Widget _buildUserResults() {
    if (_filteredUsers.isEmpty) return const Center(child: Text("No users found."));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredUsers.length,
      itemBuilder: (_, i) => UserCard(user: _filteredUsers[i]),
    );
  }
}
