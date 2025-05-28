import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/helper/background_style1.dart';
import 'package:talentloop/helper/navigation_helper.dart';
import 'package:talentloop/models/user_skill.dart';
import 'package:talentloop/services/api_services.dart';
import 'package:http/http.dart' as http;
import '../services/skill_services.dart';
import '../navigation_screens/main_navigation_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  XFile? _imageFile;
  final TextEditingController _contentController = TextEditingController();
  List<UserSkill> _skills = [];
  UserSkill? _selectedSkill;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  Future<void> _pickImage() async {
    final typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
    );

    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      if (!mounted) return;
      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _fetchSkills() async {
    try {
      List<UserSkill> skills = await SkillServices.getUserSkills();
      if (!mounted) return;
      setState(() {
        _skills = skills;
      });
    } catch (e) {
      print('Error loading skills: $e');
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.isEmpty || _selectedSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      String? base64Image;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final body = jsonEncode({
        'user_id': ApiServices.uid,
        'content': _contentController.text,
        'skill_id': _selectedSkill!.id,
        'image': base64Image ?? '',
        'status': 'active',
      });

      final response = await http.post(
        Uri.parse('${ApiServices.baseUrl}/posts'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post added successfully!')),
        );
        NavigationHelper.navigateWithSlideFromLeft(context, const MainNavigationScreen(initialIndex: 3));
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add post')),
        );
      }
    } catch (e) {
      print('Error adding post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  _buildContentInput(),
                  const SizedBox(height: 20),
                  _buildSkillDropdown(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.teal),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Text(
          'Add Post',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.tealShade50.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tealShade200),
        ),
        child: _imageFile != null
            ? FutureBuilder<Uint8List>(
          future: _imageFile!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  snapshot.data! as Uint8List,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        )
            : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40, color: AppColors.teal),
              SizedBox(height: 10),
              Text('Tap to select image', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      maxLines: 4,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        hintText: 'Write your post content...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSkillDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<UserSkill>(
        value: _selectedSkill,
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text('Select Related Skill'),
        items: _skills.map((skill) {
          return DropdownMenuItem<UserSkill>(
            value: skill,
            child: Text(skill.name),
          );
        }).toList(),
        onChanged: (value) {
          if (!mounted) return;
          setState(() => _selectedSkill = value);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _loading ? null : _submitPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Add Post', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
