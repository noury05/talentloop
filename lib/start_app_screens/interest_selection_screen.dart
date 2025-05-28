import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/helper/circle_painter.dart';
import 'package:talentloop/helper/navigation_helper.dart';
import 'package:talentloop/start_app_screens/skill_selection_screen.dart';
import '../navigation_screens/main_navigation_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({Key? key}) : super(key: key);

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  Map<dynamic, dynamic>? _categories;
  Map<dynamic, dynamic>? _skills;
  bool _loadingData = true;
  String? _errorMessage;
  final Set<String> _selectedInterestIds = {};
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final categoriesFuture = http.get(Uri.parse('http://127.0.0.1:8000/api/categories'));
      final skillsFuture = http.get(Uri.parse('http://127.0.0.1:8000/api/skills'));

      final responses = await Future.wait([categoriesFuture, skillsFuture]);

      // Check status codes.
      for (var response in responses) {
        if (response.statusCode != 200) {
          throw Exception('HTTP error: ${response.statusCode}');
        }
      }

      // Parse data.
      final categoriesData = jsonDecode(responses[0].body);
      final skillsData = jsonDecode(responses[1].body);

      setState(() {
        _categories = categoriesData;
        _skills = skillsData;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _loadingData = false;
      });
    }
  }

  Future<void> _finishInterestSelection() async {
    // Validate that at least one interest is selected.
    if (_selectedInterestIds.isEmpty) {
      setState(() {
        _saveError = "Please select at least one interest.";
      });
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _saveError = null;
          });
        }
      });
      return;
    }

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      final response = await http.post(
        // Ensure the endpoint matches your Laravel route (e.g., /api/user_interests/{uid})
        Uri.parse('http://127.0.0.1:8000/api/user_interests/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'interest_ids': _selectedInterestIds.toList(),
        }),
      );

      if (response.statusCode == 200) {
        NavigationHelper.navigateWithFade(context, const MainNavigationScreen());
      } else {
        throw Exception('Failed to save interests: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _saveError = "Error saving interests: $e";
      });
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _saveError = null;
          });
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final titleHeight = 80.0;
    final buttonHeight = 80.0;
    final availableHeight = screenHeight - titleHeight - buttonHeight - MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: CirclePainter(numberOfCircles: 4))),
          Column(
            children: [
              Container(
                height: titleHeight,
                alignment: Alignment.center,
                child: Text(
                  'Select Your Interests',
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
              ),
              _loadingData
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                  : Container(
                height: availableHeight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: ListView(
                      children: [
                        ...?_categories?.entries.map((catEntry) {
                          final categoryId = catEntry.key.toString();
                          final skillsForCategory = _skills?.entries
                              .where((skillEntry) =>
                          skillEntry.value['category_id'].toString() == categoryId)
                              .toList();

                          return Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              key: PageStorageKey(categoryId),
                              iconColor: Colors.black,
                              collapsedIconColor: Colors.black,
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              title: Text(
                                catEntry.value['name'] ?? 'Unnamed Category',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              children: skillsForCategory?.map((skillEntry) {
                                final skillId = skillEntry.key.toString();
                                final selected = _selectedInterestIds.contains(skillId);

                                return CheckboxListTile(
                                  title: Text(
                                    skillEntry.value['name'] ?? 'Unnamed Skill',
                                    style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                                  ),
                                  subtitle: Text(
                                    skillEntry.value['description'] ?? '',
                                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.black54),
                                  ),
                                  value: selected,
                                  activeColor: AppColors.teal,
                                  onChanged: (bool? value) => setState(() {
                                    if (value == true) {
                                      _selectedInterestIds.add(skillId);
                                    } else {
                                      _selectedInterestIds.remove(skillId);
                                    }
                                  }),
                                );
                              }).toList() ?? [],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Bottom Positioned area containing error message and navigation buttons.
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_saveError != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      _saveError!,
                      style: TextStyle(color: Colors.red.shade400, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          NavigationHelper.navigateWithSlideFromLeft(context, const SkillSelectionScreen()),
                      child: Text(
                        'Back',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: _saving ? null : _finishInterestSelection,
                      child: _saving
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        'Finish',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
