import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_patient.dart';
import 'package:medical_app/features/localisation/presentation/pages/pharmacie_page.dart';
import 'package:medical_app/features/messagerie/presentation/pages/conversations_list_screen.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_patient.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/payement/presentation/pages/payement.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilPatient.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousPatient.dart';
import 'package:medical_app/features/secours/presentation/pages/secours_screen.dart';
import 'package:medical_app/features/settings/presentation/pages/SettingsPage.dart';

class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  int _selectedIndex = 0;

  static final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: 60.sp),
      activeIcon: Icon(Icons.home_filled, size: 60.sp),
      label: 'Accueil',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined, size: 60.sp),
      activeIcon: Icon(Icons.calendar_today, size: 60.sp),
      label: 'Rendez-vous',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline, size: 60.sp),
      activeIcon: Icon(Icons.chat_bubble, size: 60.sp),
      label: 'Messages',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 60.sp),
      activeIcon: Icon(Icons.person, size: 60.sp),
      label: 'Profil',
    ),
  ];

  final List<Widget> _pages = [
    const Dashboardpatient(),
    const RendezVousPatient(),
    const ConversationsListScreen(isDoctor: false),
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
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: Text(
            'MediLink',
            style: GoogleFonts.raleway(
              fontSize: 60.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Badge(
                child: Icon(Icons.notifications_none, size: 60.sp, color: AppColors.whiteColor),
              ),
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
              selectedLabelStyle: GoogleFonts.raleway(fontSize: 35.sp),
              unselectedLabelStyle: GoogleFonts.raleway(fontSize: 35.sp),
              onTap: _onItemTapped,
            ),
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
                          'John Doe',
                          style: GoogleFonts.raleway(
                            fontSize: 45.sp,
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'johndoe@example.com',
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
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.calendarAlt,
                      title: 'Ordonnances',
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
                      title: 'Hôpitaux',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PharmaciePage()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.kitMedical,
                      title: 'Premiers Secours',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SecoursScreen()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.creditCard,
                      title: 'Paiements',
                      badgeCount: 1,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentsPage()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.gear,
                      title: 'Paramètres',
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
                child: _buildDrawerItem(
                  icon: FontAwesomeIcons.rightFromBracket,
                  title: 'Déconnexion',
                  onTap: () {},
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
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
      leading: Icon(icon, color: color, size: 50.sp),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.raleway(
              fontSize: 40.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (badgeCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                badgeCount.toString(),
                style: GoogleFonts.raleway(
                  fontSize: 30.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      minLeadingWidth: 50.w,
    );
  }
}