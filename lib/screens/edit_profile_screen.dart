import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker_plus/country_picker_plus.dart';
import 'package:talentloop/constants/app_colors.dart';
import 'package:talentloop/helper/background_style1.dart';
import 'package:talentloop/helper/navigation_helper.dart';
import 'package:talentloop/navigation_screens/main_navigation_screen.dart';
import 'package:talentloop/start_app_screens/skill_selection_screen.dart';

import '../helper/circle_painter.dart';
import '../services/profile_setup_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  int? _selectedAvatarIndex;
  bool _loading = false;
  String? _error;

  dynamic _selectedCountry;
  dynamic _selectedState;
  dynamic _selectedCity;

  Future<void> _saveProfile() async {
    final hasData =
        _selectedAvatarIndex != null ||
            _selectedCountry != null ||
            _selectedCity != null ||
            _bioController.text.trim().isNotEmpty;

    if (!hasData) {
      if (!mounted) return;
      setState(() => _error = "Please provide at least one piece of information.");
      return;
    }
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ProfileSetupService.updateUserProfile(
        avatarIndex: _selectedAvatarIndex,
        country: _selectedCountry, // <-- no .name
        state: _selectedState,      // <-- no .name
        city: _selectedCity,        // <-- no .name
        bio: _bioController.text.trim(),
      );
      NavigationHelper.navigateWithSlideFromLeft(
        context, const MainNavigationScreen(initialIndex: 3),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Error updating profile: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          Positioned.fill(child: BackgroundStyle1()),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 600),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildAvatarGrid(),
                const SizedBox(height: 30),
                _buildFormFields(),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  _buildError(),
                ],
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child:Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.teal),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Edit Profile',
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
    );
  }

  Widget _buildAvatarGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select an Avatar',
            style: GoogleFonts.roboto(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8),
            itemCount: 12,
            itemBuilder: (context, index) => _buildAvatarItem(index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarItem(int avatarNumber) {
    final isSelected = _selectedAvatarIndex == avatarNumber;
    return GestureDetector(
      onTap: () => mounted?setState(() => _selectedAvatarIndex = avatarNumber):null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: isSelected ? AppColors.coral : Colors.transparent,
            child: CircleAvatar(
              radius: 38,
              backgroundImage:
              AssetImage('assets/avatars/$avatarNumber.jpg'),
            ),
          ),
          if (isSelected)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountryPickerPlus(
          hideFields: false,
          countryLabel: 'Country',
          stateLabel: 'State',
          cityLabel: 'City',
          countryHintText: 'Tap to select country',
          stateHintText: _selectedCountry == null
              ? 'Select country first'
              : 'Tap to select state',
          cityHintText: _selectedState == null
              ? 'Select state first'
              : 'Tap to select city',
          decoration: CPPFDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.coral),
            ),
            innerColor: Colors.transparent,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.coral),
            ),
          ),
          onCountrySelected: (country) {
            if (!mounted) return;
            setState(() {
              _selectedCountry = country;
              _selectedState = null;
              _selectedCity = null;
            });
          },
          onStateSelected: (state) {
            if (!mounted) return;
            setState(() {
              _selectedState = state;
              _selectedCity = null;
            });
          },
          onCitySelected: (city) {
            if (!mounted) return;
            setState(() => _selectedCity = city);
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Bio',
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 45),
              child: Icon(Icons.info_outline, color: Colors.black),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 40),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.coral),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.coral),
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _error!,
        style: TextStyle(color: Colors.red.shade400, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons() {
    return _loading
        ? const CircularProgressIndicator(color: AppColors.coral)
        : Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: _saveProfile,
          child: Text(
            'Save Profile',
            style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      ],
    );
  }
}
