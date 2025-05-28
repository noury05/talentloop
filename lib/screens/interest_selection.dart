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

class InterestSelection extends StatefulWidget {
  const InterestSelection({Key? key}) : super(key: key);

  @override
  State<InterestSelection> createState() => _InterestSelectionState();
}

class _InterestSelectionState extends State<InterestSelection> {
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
      if (!mounted) return;
      setState(() {
        _categories = categoriesData;
        _skills = skillsData;
        _loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _loadingData = false;
      });
    }
  }

  Future<void> _finishInterestSelection() async {
    // Validate that at least one interest is selected.
    if (_selectedInterestIds.isEmpty) {
      if (!mounted) return;
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
    if (!mounted) return;
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
        NavigationHelper.navigateWithFade(context, const MainNavigationScreen(initialIndex: 3,));
      } else {
        throw Exception('Failed to save interests: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
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
                        'Edit Interests',
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
                                  onChanged: (bool? value) =>mounted? setState(() {
                                    if (value == true) {
                                      _selectedInterestIds.add(skillId);
                                    } else {
                                      _selectedInterestIds.remove(skillId);
                                    }
                                  }):null,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _saving ? null : _finishInterestSelection,
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
