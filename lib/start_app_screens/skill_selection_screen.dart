import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/helper/circle_painter.dart';
import 'package:talentloop/helper/navigation_helper.dart';
import 'package:talentloop/start_app_screens/profile_setup_screen.dart';
import 'package:talentloop/start_app_screens/interest_selection_screen.dart';

class SkillSelectionScreen extends StatefulWidget {
  const SkillSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SkillSelectionScreen> createState() => _SkillSelectionScreenState();
}

class _SkillSelectionScreenState extends State<SkillSelectionScreen> {
  Map<dynamic, dynamic>? _categories;
  Map<dynamic, dynamic>? _skills;
  bool _loadingData = true;
  String? _errorMessage;
  final Set<String> _selectedSkillIds = {};
  bool _saving = false;
  String? _saveError;

  final Map<String, String> _skillProficiency = {};
  final Map<String, String> _skillYear = {};

  final List<String> _proficiencyLevels = [
    'Beginner', 'Intermediate', 'Advanced', 'Expert', 'Master'
  ];

  final List<String> _years = List<String>.generate(
      DateTime.now().year - 1999, (index) => (2000 + index).toString());

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch categories and skills from the Laravel API.
  Future<void> _fetchData() async {
    try {
      final categoriesFuture = http.get(Uri.parse('http://127.0.0.1:8000/api/categories'));
      final skillsFuture = http.get(Uri.parse('http://127.0.0.1:8000/api/skills'));

      final responses = await Future.wait([categoriesFuture, skillsFuture]);

      // Check for HTTP errors.
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

  Future<void> _finishSkillSelection() async {
    // Reset any previous error message.
    setState(() {
      _saveError = null;
    });

    // Collect validation errors.
    List<String> errors = [];

    // 1. Ensure at least one skill is selected.
    if (_selectedSkillIds.isEmpty) {
      errors.add("Please select at least one skill.");
    } else {
      // 2. For each selected skill, ensure that both proficiency and acquired year are chosen.
      for (var skillId in _selectedSkillIds) {
        if (_skillProficiency[skillId] == null || _skillYear[skillId] == null) {
          // Try to get the skill name from _skills; if not available, show a generic message.
          final String skillName = _skills?[skillId]?['name'] ?? "selected skill";
          errors.add("Please select proficiency and acquired year for $skillName.");
        }
      }
    }

    // If there are any errors, display them and clear after 5 seconds.
    if (errors.isNotEmpty) {
      setState(() {
        _saveError = errors.join("\n");
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

    // Proceed with submission if validation passed.
    try {
      setState(() {
        _saving = true;
      });
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      final List<Map<String, dynamic>> skills = [];
      for (var skillId in _selectedSkillIds) {
        skills.add({
          'skill_id': skillId,
          'proficiency': _skillProficiency[skillId],
          'year_acquired': _skillYear[skillId],
        });
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/user_skills/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'skills': skills}),
      );

      if (response.statusCode == 200) {
        NavigationHelper.navigateWithSlideFromRight(context, const InterestSelectionScreen());
      } else {
        throw Exception('Failed to save interests: ${response.body}');
      }
    } catch (e) {
      setState(() => _saveError = "Error saving interests: $e");
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
                  'Select Your Skills',
                  style: GoogleFonts.roboto(
                    fontSize: 25,
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
                          final skillsForCategory = _skills?.entries.where((skillEntry) =>
                          skillEntry.value['category_id'].toString() == categoryId).toList();

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
                                final selected = _selectedSkillIds.contains(skillId);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CheckboxListTile(
                                      title: Text(
                                        skillEntry.value['name'] ?? 'Unnamed Skill',
                                        style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                                      ),
                                      value: selected,
                                      activeColor: AppColors.teal,
                                      onChanged: (bool? value) => setState(() {
                                        if (value == true) {
                                          _selectedSkillIds.add(skillId);
                                        } else {
                                          _selectedSkillIds.remove(skillId);
                                          _skillProficiency.remove(skillId);
                                          _skillYear.remove(skillId);
                                        }
                                      }),
                                    ),
                                    if (selected)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0, bottom: 12),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: DropdownButtonFormField<String>(
                                                isExpanded: true,
                                                decoration: const InputDecoration(
                                                  labelText: 'Proficiency',
                                                  border: OutlineInputBorder(),
                                                ),
                                                value: _skillProficiency[skillId],
                                                onChanged: (val) => setState(() => _skillProficiency[skillId] = val!),
                                                items: _proficiencyLevels
                                                    .map((level) => DropdownMenuItem(
                                                  value: level,
                                                  child: Text(level, overflow: TextOverflow.ellipsis),
                                                ))
                                                    .toList(),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: DropdownButtonFormField<String>(
                                                isExpanded: true,
                                                decoration: const InputDecoration(
                                                  labelText: 'Acquired',
                                                  border: OutlineInputBorder(),
                                                ),
                                                value: _skillYear[skillId],
                                                onChanged: (val) => setState(() => _skillYear[skillId] = val!),
                                                items: _years
                                                    .map((year) => DropdownMenuItem(
                                                  value: year,
                                                  child: Text(year, overflow: TextOverflow.ellipsis),
                                                ))
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
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
                      onPressed: () => NavigationHelper.navigateWithSlideFromLeft(
                          context, const ProfileSetupScreen()),
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
                      onPressed: _saving ? null : _finishSkillSelection,
                      child: _saving
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        'Next',
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
