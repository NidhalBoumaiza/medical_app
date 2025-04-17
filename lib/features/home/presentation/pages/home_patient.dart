import 'package:flutter/material.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_patient.dart';
import 'package:medical_app/features/messagerie/presentation/pages/messagerie_patient.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_patient.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilPatient.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousPatient.dart';

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
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Rendez-vous"),
    BottomNavigationBarItem(icon: Icon(Icons.generating_tokens_sharp), label: "AI"),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profil"),

  ];
  List<Widget> pages = [
    Dashboardpatient(),
    RendezVousPatient(),
    SettingsPatient(),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent,Color(0xFF2FA7BB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MessageriePatient()));
          },
          child: Icon(Icons.message_outlined),
          backgroundColor: Colors.transparent, // Transparent background
          elevation: 0,
        ),
      ),
      //menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 35)),
              decoration: BoxDecoration(color: Color(0xFF2FA7BB),),
            ),

            ListTile(
              leading: Icon(Icons.description),
              title: Text("Ordonnances"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdonnancesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services_outlined),
              title: Text("Premier Secours"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecoursScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Paramètres"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

