import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_patient.dart';
import 'package:medical_app/features/localisation/presentation/pages/pharmacie_page.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_patient.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/payement/presentation/pages/payement.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilPatient.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousPatient.dart';
import 'package:medical_app/features/secours/presentation/pages/secours_screen.dart';
import 'package:medical_app/features/settings/presentation/pages/SettingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../authentication/presentation/pages/login_screen.dart';
import '../../../messagerie/presentation/pages/conversations_list_screen.dart';
import '../../../profile/presentation/pages/blocs/BLoC update profile/update_user_bloc.dart';
import '../../../rendez_vous/presentation/pages/appointments.dart';

class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  int _selectedIndex = 0;
  String userId = '';
  String patientName = 'John Doe';
  String email = 'johndoe@example.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      print ('User JSON: $userJson');
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        userId = userMap['id'] as String? ?? '';
        patientName = '${userMap['name'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
        email = userMap['email'] as String? ?? 'johndoe@example.com';
      });
    }
  }

  static final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: 60.sp),
      activeIcon: Icon(Icons.home_filled, size: 70.sp),
      label: 'home'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined, size: 60.sp),
      activeIcon: Icon(Icons.calendar_today, size: 70.sp),
      label: 'appointments'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline, size: 60.sp),
      activeIcon: Icon(Icons.chat_bubble, size: 70.sp),
      label: 'messages'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 60.sp),
      activeIcon: Icon(Icons.person, size: 70.sp),
      label: 'profile'.tr,
    ),
  ];

  late List<Widget> _pages = [
    const Dashboardpatient(),
    const AppointmentsPage(),
    ConversationsScreen(),
    const ProfilePatient(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNotificationTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPatient()),
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('confirm logout'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('CACHED_USER');
                await prefs.remove('TOKEN');

                // Use Get.offAll instead of Get.offAllNamed for more reliable navigation
                Get.offAll(() => LoginScreen());

                // Optional: show success message
                Get.snackbar(
                  'Success',
                  'Logged out successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                // Show error message if logout fails
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                print("Logout error: $e");
              }
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
    int badgeCount = 0,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 60.sp),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.raleway(
              fontSize: 50.sp,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          if (badgeCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Text(
                badgeCount.toString(),
                style: GoogleFonts.raleway(
                  fontSize: 50.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
      minLeadingWidth: 50.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    print ("1111111111111111111111111111111") ;
    print ("userId : $userId") ;
    return SafeArea(
      child: BlocListener<UpdateUserBloc, UpdateUserState>(
        listener: (context, state) {
          if (state is UpdateUserSuccess) {
            setState(() {
              patientName = '${state.user.name} ${state.user.lastName}'.trim();
              email = state.user.email;
              userId = state.user.id ?? '';
              _pages = [
                const Dashboardpatient(),
                const RendezVousPatient(),
                ConversationsScreen(),
                const ProfilePatient(),
              ];
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            title: Text(
              'MediLink',
              style: GoogleFonts.raleway(
                fontSize: 70.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none, size: 70.sp, color: AppColors.whiteColor),
                onPressed: _onNotificationTapped,
              ),
            ],
          ),
          body: _pages[_selectedIndex],

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: BottomNavigationBar(
                items: _navItems,
                currentIndex: _selectedIndex,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: AppColors.textSecondary,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.whiteColor,
                elevation: 10,
                selectedLabelStyle: GoogleFonts.raleway(fontSize: 50.sp,fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.raleway(fontSize: 45.sp,fontWeight: FontWeight.bold),
                onTap: _onItemTapped,
              ),
            ),
          ),

          //menu
          drawer: Drawer(
            width: 0.8.sw,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            ),
            backgroundColor: const Color(0xFF2fa7bb),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50.h, left: 25.w, right: 25.w, bottom: 30.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 80.r,
                        backgroundColor: AppColors.whiteColor,
                        child: Icon(
                          Icons.person,
                          size: 80.sp,
                          color: const Color(0xFF2fa7bb),
                        ),
                      ),
                      SizedBox(width: 25.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: GoogleFonts.raleway(
                                fontSize: 70.sp,
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              email,
                              style: GoogleFonts.raleway(
                                fontSize: 60.sp,
                                color: AppColors.whiteColor.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 1,
                  height: 1,
                ),
                SizedBox(height: 15.h),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    children: [
                      _buildDrawerItem(
                        icon: FontAwesomeIcons.filePrescription,
                        title: 'prescriptions'.tr,
                        badgeCount: 2,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrdonnancesPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: FontAwesomeIcons.hospital,
                        title: 'hospitals'.tr,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PharmaciePage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: FontAwesomeIcons.kitMedical,
                        title: 'first_aid'.tr,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SecoursScreen()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: FontAwesomeIcons.creditCard,
                        title: 'payments'.tr,
                        badgeCount: 1,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentsPage()),
                          );
                        },
                      ),

                    ],
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(0.3),
                  thickness: 1,
                  height: 1,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
                  child: _buildDrawerItem(
                    icon: FontAwesomeIcons.rightFromBracket,
                    title: 'Logout'.tr,
                    onTap: _logout,
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}