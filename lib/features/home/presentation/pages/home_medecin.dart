import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_medecin.dart';
import 'package:medical_app/features/messagerie/presentation/pages/conversations_list_screen.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_medecin.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilMedecin.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousMedecin.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import '../../../settings/presentation/pages/SettingsPage.dart';

class HomeMedecin extends StatefulWidget {
  const HomeMedecin({super.key});

  @override
  State<HomeMedecin> createState() => _HomeMedecinState();
}

class _HomeMedecinState extends State<HomeMedecin> {
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
  List<Widget> pages = [
    const DashboardMedecin(),
    const RendezVousMedecin(),
    const ConversationsListScreen(isDoctor: true),
    const ProfilMedecin(),
  ];

  int selectedItem = 0;

  void _onNotificationTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsMedecin()),
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
                  builder: (context) => const ConversationsListScreen(isDoctor: true),
                ),
              );
            },
            child: Icon(Icons.message_outlined, size: 60.sp),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Text(
                  "Menu",
                  style: GoogleFonts.raleway(
                    fontSize: 70.sp,
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                decoration: BoxDecoration(color: AppColors.primaryColor),
              ),
              ListTile(
                leading: Icon(Icons.description, size: 60.sp),
                title: Text(
                  "Ordonnances",
                  style: GoogleFonts.raleway(fontSize: 45.sp),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrdonnancesPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, size: 60.sp),
                title: Text(
                  "Paramètres",
                  style: GoogleFonts.raleway(fontSize: 45.sp),
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
      ),
    );
  }
}