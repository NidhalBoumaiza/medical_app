import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/widgets/theme_cubit_switch.dart';
import 'package:medical_app/i18n/app_translation.dart';

class SettingsPatient extends StatefulWidget {
  const SettingsPatient({super.key});

  @override
  State<SettingsPatient> createState() => _SettingsPatientState();
}

class _SettingsPatientState extends State<SettingsPatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "settings".tr,
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 24,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("appearance".tr),
            const SizedBox(height: 8),
            const ThemeCubitSwitch(),
            
            const SizedBox(height: 24),
            _buildSectionTitle("language".tr),
            const SizedBox(height: 8),
            _buildLanguageSelection(),
            
            const SizedBox(height: 24),
            _buildSectionTitle("notifications".tr),
            const SizedBox(height: 8),
            _buildNotificationSettings(),
            
            const SizedBox(height: 24),
            _buildSectionTitle("about".tr),
            const SizedBox(height: 8),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.raleway(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
  
  Widget _buildLanguageSelection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildLanguageOption('Français', 'fr'),
            const Divider(height: 1),
            _buildLanguageOption('English', 'en'),
            const Divider(height: 1),
            _buildLanguageOption('العربية', 'ar'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageOption(String language, String langCode) {
    final isSelected = Get.locale?.languageCode == langCode;
    
    return InkWell(
      onTap: () async {
        Get.updateLocale(Locale(langCode));
        await LanguageService.saveLanguage(langCode);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: GoogleFonts.raleway(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationSettings() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildSwitchSetting(
              title: "appointments".tr, 
              icon: Icons.calendar_today,
              value: true,
            ),
            const Divider(height: 1),
            _buildSwitchSetting(
              title: "medications".tr, 
              icon: Icons.medication,
              value: true,
            ),
            const Divider(height: 1),
            _buildSwitchSetting(
              title: "messages".tr, 
              icon: Icons.message,
              value: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitchSetting({
    required String title,
    required IconData icon,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.raleway(fontSize: 14),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: (val) {
              // Implement notification settings logic
              setState(() {});
            },
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Medical App v1.0.0",
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "copyright".tr,
              style: GoogleFonts.raleway(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
