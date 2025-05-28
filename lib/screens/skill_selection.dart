import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/helper/navigation_helper.dart';

import '../helper/background_style1.dart';
import '../navigation_screens/main_navigation_screen.dart';

class SkillSelection extends StatefulWidget {
  const SkillSelection({Key? key}) : super(key: key);

  @override
  State<SkillSelection> createState() => _SkillSelectionState();
}

class _SkillSelectionState extends State<SkillSelection> {
  Map<dynamic, dynamic>? _categories;
  Map<dynamic, dynamic>? _skills;
  bool _loading = true;
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

  Future<void> _fetchData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in.');

      final responses = await Future.wait([
        http.get(Uri.parse('http://127.0.0.1:8000/api/categories')),
        http.get(Uri.parse('http://127.0.0.1:8000/api/skills/available/$uid')),
      ]);

      for (var response in responses) {
        if (response.statusCode != 200) {
          throw Exception('HTTP error: ${response.statusCode}');
        }
      }

      final categoriesData = jsonDecode(responses[0].body);
      final skillsData = jsonDecode(responses[1].body);
      if (!mounted) return;
      setState(() {
        _categories = categoriesData;
        _skills = skillsData;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _updateSkills() async {
    if (_selectedSkillIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        _saveError = "Please select at least one skill.";
      });
      return;
    }

    for (var skillId in _selectedSkillIds) {
      if (_skillProficiency[skillId] == null || _skillYear[skillId] == null) {
        if (!mounted) return;
        setState(() {
          _saveError = "Please complete all fields.";
        });
        return;
      }
    }
    try {
      if (!mounted) return;
      setState(() => _saving = true);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      final skills = _selectedSkillIds.map((skillId) => {
        'skill_id': skillId,
        'proficiency': _skillProficiency[skillId],
        'year_acquired': _skillYear[skillId],
      }).toList();

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/user_skills/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'skills': skills}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
           NavigationHelper.navigateWithSlideFromLeft(context, const MainNavigationScreen(initialIndex: 3));
        }
      } else {
        throw Exception('Failed to update skills: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveError = "Error saving skills: $e";
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
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          const BackgroundStyle1(),
          Column(
            children: [
              const SizedBox(height: 20,),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.teal),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Edit Skills',
                        style: GoogleFonts.roboto(
                          color: AppColors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20,),
              _loading
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
                                      onChanged: (bool? value) =>mounted? setState(() {
                                        if (value == true) {
                                          _selectedSkillIds.add(skillId);
                                        } else {
                                          _selectedSkillIds.remove(skillId);
                                          _skillProficiency.remove(skillId);
                                          _skillYear.remove(skillId);
                                        }
                                      }):null,
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
                                                onChanged: (val) =>mounted? setState(() => _skillProficiency[skillId] = val!):null,
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
                                                onChanged: (val) => mounted?setState(() => _skillYear[skillId] = val!):null,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _saving ? null : _updateSkills,
                      child: _saving
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : Text(
                        'Update',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
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



