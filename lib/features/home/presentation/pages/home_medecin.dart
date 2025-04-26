import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_medecin.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_medecin.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilMedecin.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousMedecin.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../messagerie/presentation/pages/conversations_list_screen.dart';
import '../../../settings/presentation/pages/SettingsPage.dart';

class HomeMedecin extends StatefulWidget {
  const HomeMedecin({super.key});

  @override
  State<HomeMedecin> createState() => _HomeMedecinState();
}

class _HomeMedecinState extends State<HomeMedecin> {
  int selectedItem = 0;
  String userId = '';
  String doctorName = 'Dr. Unknown';
  String email = 'doctor@example.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        userId = userMap['id'] as String? ?? '';
        doctorName = '${userMap['name'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
        email = userMap['email'] as String? ?? 'doctor@example.com';
      });
    }
  }

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home, size: 60.sp),
      label: "Accueil",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today, size: 60.sp),
      label: "Rendez-vous",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message_outlined, size: 60.sp),
      label: "Messages",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle, size: 60.sp),
      label: "Profil",
    ),
  ];

  late List<Widget> pages = [
    const DashboardMedecin(),
    const RendezVousMedecin(),
    ConversationsScreen(isDoctor: true, userId: userId),
    const ProfilMedecin(),
  ];

  void _onNotificationTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsMedecin()),
    );
  }

  void _logout() {
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
              Get.offAllNamed('/login');
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: ReusableTextWidget(
            text: "MediLink",
            textSize: 85,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
            letterSpacing: 1.5,
          ),
          backgroundColor: AppColors.primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, size: 60.sp, color: AppColors.whiteColor),
              onPressed: _onNotificationTapped,
            ),
          ],
        ),
        body: pages[selectedItem],
        bottomNavigationBar: BottomNavigationBar(
          items: items,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: selectedItem,
          selectedLabelStyle: GoogleFonts.raleway(fontSize: 35.sp),
          unselectedLabelStyle: GoogleFonts.raleway(fontSize: 35.sp),
          onTap: (index) {
            setState(() {
              selectedItem = index;
            });
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.tealAccent, AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationsScreen(isDoctor: true, userId: userId),
                ),
              );
            },
            child: Icon(Icons.message_outlined, size: 60.sp),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        drawer: Drawer(
          width: 0.8.sw,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
          ),
          backgroundColor: const Color(0xFF3F51B5),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 80.h, left: 20.w, right: 20.w, bottom: 20.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: AppColors.whiteColor,
                      child: Icon(
                        Icons.person,
                        size: 60.sp,
                        color: const Color(0xFF3F51B5),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: GoogleFonts.raleway(
                            fontSize: 45.sp,
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          email,
                          style: GoogleFonts.raleway(
                            fontSize: 35.sp,
                            color: AppColors.whiteColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.description, size: 60.sp, color: AppColors.whiteColor),
                      title: Text(
                        "Ordonnances",
                        style: GoogleFonts.raleway(fontSize: 45.sp, color: AppColors.whiteColor),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrdonnancesPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings, size: 60.sp, color: AppColors.whiteColor),
                      title: Text(
                        "Paramètres",
                        style: GoogleFonts.raleway(fontSize: 45.sp, color: AppColors.whiteColor),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.rightFromBracket, size: 50.sp, color: Colors.red),
                  title: Text(
                    'Déconnexion',
                    style: GoogleFonts.raleway(
                      fontSize: 40.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}