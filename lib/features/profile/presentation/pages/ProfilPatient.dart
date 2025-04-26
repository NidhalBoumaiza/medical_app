import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/theme_provider.dart';

class ProfilePatient extends StatefulWidget {
  const ProfilePatient({Key? key}) : super(key: key);

  @override
  State<ProfilePatient> createState() => _ProfilePatientState();
}

class _ProfilePatientState extends State<ProfilePatient> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

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
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        _nameController.text = '${userMap['name'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
        _emailController.text = userMap['email'] as String? ?? '';
        _phoneController.text = userMap['phoneNumber'] as String? ?? '';
        _addressController.text = ''; // Address not stored in UserModel
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('CACHED_USER');
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final nameParts = _nameController.text.trim().split(' ');
        userMap['name'] = nameParts.isNotEmpty ? nameParts[0] : '';
        userMap['lastName'] = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        userMap['email'] = _emailController.text;
        userMap['phoneNumber'] = _phoneController.text;
        // Note: Address not stored in UserModel; consider adding to Firestore if needed
        await prefs.setString('CACHED_USER', jsonEncode(userMap));
        Get.snackbar(
          'success'.tr,
          'profile_saved_successfully'.tr,
          backgroundColor: Colors.green,
          colorText: AppColors.whiteColor,
        );
      }
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

  void _changeLanguage(String? newValue) {
    if (newValue != null) {
      setState(() => _selectedLanguage = newValue);
      final localeCode = _languageCodes[newValue];
      if (localeCode != null) Get.updateLocale(Locale(localeCode));
    }
  }

  void _changeProfilePicture() {
    Get.snackbar('info'.tr, 'change_profile_picture_message'.tr);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'save'.tr,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryColor,
                      ),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'first_name_label'.tr,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'name_required'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr,
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'email_required'.tr;
                  if (!value!.contains('@')) return 'invalid_email_message'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'phone_number_label'.tr,
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value?.isEmpty ?? true ? 'phone_number_required'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'address'.tr,
                  prefixIcon: const Icon(Icons.location_on),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
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
                  items: _languages.map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  )).toList(),
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
                onTap: () {
                  Get.toNamed('/appointments');
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text('aide_et_assistance_technique'.tr),
                onTap: () {
                  Get.toNamed('/help');
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text('logout'.tr),
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}