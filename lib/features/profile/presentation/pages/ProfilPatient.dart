import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/features/authentication/domain/entities/patient_entity.dart';
import 'package:medical_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/theme_provider.dart';
import '../../../authentication/presentation/pages/login_screen.dart';
import 'blocs/BLoC update profile/update_user_bloc.dart';

class ProfilePatient extends StatefulWidget {
  const ProfilePatient({Key? key}) : super(key: key);

  @override
  State<ProfilePatient> createState() => _ProfilePatientState();
}

class _ProfilePatientState extends State<ProfilePatient> {
  PatientEntity? _patient;
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
        _patient = PatientEntity(
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
          antecedent: userMap['antecedent'] as String,
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
        title: Text('logout'.tr, style: GoogleFonts.raleway(fontSize: 22.sp)),
        content: Text('confirm_logout'.tr, style: GoogleFonts.raleway(fontSize: 18.sp)),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr, style: GoogleFonts.raleway(fontSize: 16.sp)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Déconnexion réussie", style: GoogleFonts.raleway(fontSize: 16.sp))),
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text('logout'.tr, style: GoogleFonts.raleway(fontSize: 16.sp, color: Colors.red)),
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
          title: Text('Profile'.tr, style: GoogleFonts.raleway(fontSize: 50.sp, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          actions: [
            IconButton(
              icon: Icon(Icons.edit, size: 70.sp),
              onPressed: () {
                if (_patient != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: _patient!),
                    ),
                  ).then((updatedUser) {
                    if (updatedUser != null) {
                      context.read<UpdateUserBloc>().add(UpdateUserEvent(updatedUser as PatientEntity));
                    }
                  });
                }
              },
              tooltip: 'edit_profile'.tr,
            ),
          ],
        ),
        body: BlocConsumer<UpdateUserBloc, UpdateUserState>(
          listener: (context, state) {
            if (state is UpdateUserSuccess) {
              setState(() {
                _patient = state.user as PatientEntity;
              });
              showSuccessSnackBar(context, 'profile_saved_successfully'.tr);
            } else if (state is UpdateUserFailure) {
              showErrorSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is UpdateUserLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _patient == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 150.r,
                          backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 200.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 90.sp,
                            height: 200.sp,
                            decoration: BoxDecoration(
                             color: AppColors.iconColor,
                              shape: BoxShape.circle,

                            ),
                            child: IconButton(
                              icon: Icon(Icons.edit, color: AppColors.whiteColor, size: 50.sp),
                              onPressed: _changeProfilePicture,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildInfoTile('first_name_label'.tr, '${_patient!.name} ${_patient!.lastName}'),
                  _buildInfoTile('email'.tr, _patient!.email),
                  _buildInfoTile('phone_number_label'.tr, _patient!.phoneNumber),
                  _buildInfoTile('gender'.tr, _patient!.gender),
                  _buildInfoTile('date_of_birth_label'.tr,
                      _patient!.dateOfBirth?.toIso8601String().split('T').first ?? 'Non spécifiée'),
                  _buildInfoTile('antecedent'.tr, _patient!.antecedent),
                  SizedBox(height: 28.h),
                  Divider(color: Theme.of(context).dividerColor),

                  SwitchListTile(
                    title: Text('notifications'.tr),
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                    secondary: Icon(Icons.notifications),
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
                    secondary: Icon(Icons.brightness_6),
                    activeColor: AppColors.primaryColor,
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('mes_rendez_vous'.tr),
                    onTap: () => Get.toNamed('/appointments'),
                  ),
                  ListTile(
                    leading: Icon(Icons.help),
                    title: Text('aide_et_assistance_technique'.tr),
                    onTap: () => Get.toNamed('/help'),
                  ),
                  SizedBox(height: 28.h),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.raleway(
          fontSize: 50.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.raleway(
          fontSize: 50.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.black,
        ),
      ),
    );
  }
}