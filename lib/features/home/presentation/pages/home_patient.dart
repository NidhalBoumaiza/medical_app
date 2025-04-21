import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_patient.dart';
import 'package:medical_app/features/localisation/presentation/pages/pharmacie_page.dart';
import 'package:medical_app/features/messagerie/presentation/pages/messagerie_patient.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_patient.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilPatient.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousPatient.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../widgets/reusable_text_widget.dart';
import '../../../ordonnance/presentation/pages/OrdonnancesPage.dart';
import '../../../secours/presentation/pages/secours_screen.dart';
import '../../../settings/presentation/pages/SettingsPage.dart';
import '../../../settings/presentation/pages/settings_patient.dart';

class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.home), label: "Accueil"),
    BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.calendar), label: "Rendez-vous"),
    BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.message), label: "Messagerie"),
    BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.user), label: "Profil"),
  ];




  List<Widget> pages = [
    Dashboardpatient(),
    RendezVousPatient(),
    MessageriePatient(),
    ProfilePatient(),

  ];
  int selectedItem = 0;

  void _onNotificationTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ReusableTextWidget(
          text: "MediLink",
          textSize: 85,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
        backgroundColor: Color(0xFF2FA7BB),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: _onNotificationTapped,
          ),
        ],
      ),
      body: pages[selectedItem],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        selectedItemColor:Color.fromRGBO(20, 90, 110, 1), // Teal vif
        unselectedItemColor:  Color(0xFF2FA7BB),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: selectedItem,
        onTap: (index) {
          setState(() {
            selectedItem = index;
          });
        },
      ),
      //chatbotbutton



      //menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: 20),
          children: [
            // Compact header using Container instead of DrawerHeader
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MediLink",
                    style: TextStyle(
                      color:AppColors.primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  Text(
                    "Votre santé, notre priorité ",
                    style: TextStyle(
                      color:AppColors.primaryColor,
                      fontSize: 14, // Slightly smaller font size

                    ),
                  ),
                ],
              ),
            ),


            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.filePrescription,
                color: Color(0xFF2FA7BB),
              ),
              title: const Text(
                "Ordonnances",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdonnancesPage()),
                );
              },
            ),
            ListTile(
              leading: const FaIcon(
                //FontAwesomeIcons.prescriptionBottle,
                FontAwesomeIcons.houseChimneyMedical,
                color: Color(0xFF3DC481),
              ),
              title: const Text(
                "Hopitaux",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PharmaciePage()),
                );
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.kitMedical,
                color: Color(0xFFDA0606),
              ),
              title: const Text(
                "Premiers Secours",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecoursScreen()),
                );
              },
            ),
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.gear,
                color: Color(0xFF171818),
              ),
              title: const Text(
                "Paramètres",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
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
      ),    );
  }
}

