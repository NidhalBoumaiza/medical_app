import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/theme_provider.dart';

class ProfilMedecin extends StatefulWidget {
  const ProfilMedecin({Key? key}) : super(key: key);

  @override
  State<ProfilMedecin> createState() => _ProfilMedecinState();
}

class _ProfilMedecinState extends State<ProfilMedecin> {
  MedecinEntity? _medecin;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Français';
  final List<String> _languages = ['Français', 'English', 'العربية'];
  final Map<String, String> _languageCodes = {
    'Français': 'fr',
    'English': 'en',
    'العربية': 'ar'
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _getLanguageFromLocale(Get.locale?.languageCode ?? 'fr');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        _medecin = MedecinEntity(
          id: userMap['id'] as String?,
          name: userMap['name'] as String,
          lastName: userMap['lastName'] as String,
          email: userMap['email'] as String,
          role: userMap['role'] as String,
          gender: userMap['gender'] as String,
          phoneNumber: userMap['phoneNumber'] as String,
          dateOfBirth: userMap['dateOfBirth'] != null
              ? DateTime.parse(userMap['dateOfBirth'] as String)
              : null,
          speciality: userMap['speciality'] as String,
          numLicence: userMap['numLicence'] as String,
        );
      });
    }
  }

  String _getLanguageFromLocale(String localeCode) {
    switch (localeCode) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ar': return 'العربية';
      default: return 'Français';
    }
  }

  void _changeLanguage(String? newValue) {
    if (newValue != null) {
      setState(() => _selectedLanguage = newValue);
      final localeCode = _languageCodes[newValue];
      if (localeCode != null) Get.updateLocale(Locale(localeCode));
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('confirm_logout'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _changeProfilePicture() {
    Get.snackbar('info'.tr, 'change_profile_picture_message'.tr);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('profile'.tr),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                if (_medecin != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: _medecin!),
                    ),
                  ).then((updatedUser) {
                    if (updatedUser != null) {
                      setState(() {
                        _medecin = updatedUser as MedecinEntity;
                      });
                    }
                  });
                }
              },
              tooltip: 'edit_profile'.tr,
            ),
          ],
        ),
        body: _medecin == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      backgroundImage: const AssetImage('assets/images/profil.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.whiteColor, size: 20),
                          onPressed: _changeProfilePicture,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _buildInfoTile('Nom', '${_medecin!.name} ${_medecin!.lastName}'),
              _buildInfoTile('Email', _medecin!.email),
              _buildInfoTile('Téléphone', _medecin!.phoneNumber),
              _buildInfoTile('Genre', _medecin!.gender),
              _buildInfoTile('Date de naissance',
                  _medecin!.dateOfBirth?.toIso8601String().split('T').first ?? 'Non spécifiée'),
              _buildInfoTile('Spécialité', _medecin!.speciality),
              _buildInfoTile('Numéro de licence', _medecin!.numLicence),
              SizedBox(height: 24.h),
              Divider(color: Theme.of(context).dividerColor),
              SwitchListTile(
                title: Text('notifications'.tr),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
                secondary: const Icon(Icons.notifications),
                activeColor: AppColors.primaryColor,
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('language'.tr),
                trailing: DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: _changeLanguage,
                  items: _languages
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                ),
              ),
              SwitchListTile(
                title: Text('dark_mode'.tr),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                secondary: const Icon(Icons.brightness_6),
                activeColor: AppColors.primaryColor,
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('mes_rendez_vous'.tr),
                onTap: () => Get.toNamed('/appointments'),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text('aide_et_assistance_technique'.tr),
                onTap: () => Get.toNamed('/help'),
              ),
              SizedBox(height: 24.h),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text('logout'.tr),
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.raleway(fontSize: 40.sp, color: AppColors.grey),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.raleway(fontSize: 48.sp, color: AppColors.black),
      ),
    );
  }
}