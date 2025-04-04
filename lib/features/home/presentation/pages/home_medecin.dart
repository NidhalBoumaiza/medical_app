import 'package:flutter/material.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_medecin.dart';
import 'package:medical_app/features/messagerie/presentation/pages/messagerie_medecin.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_medecin.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilMedecin.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousMedecin.dart';

import '../../../../widgets/reusable_text_widget.dart';
import '../../../authentication/domain/usecases/login_screen.dart';
import '../../../settings/presentation/pages/SettingsPage.dart';

class HomeMedecin extends StatefulWidget {
  const HomeMedecin({super.key});

  @override
  State<HomeMedecin> createState() => _HomeMedecinState();
}

class _HomeMedecinState extends State<HomeMedecin> {
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Rendez-vous"),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messagerie"),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profil"),
  ];
  List<Widget> pages = [
    DashboardMedecin(),
    RendezVousMedecin(),
    MessagerieMedecin(),
    ProfilMedecin(),
  ];

  int selectedItem = 0;

  void _onNotificationTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsMedecin()),
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
        selectedItemColor: Color.fromRGBO(20, 90, 110, 1),
        unselectedItemColor: Color(0xFF2FA7BB),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: selectedItem,
        onTap: (index) {
          setState(() {
            selectedItem = index;
          });
        },
      ),

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