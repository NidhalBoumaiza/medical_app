import 'package:flutter/material.dart';
import 'package:medical_app/features/dashboard/presentation/pages/DashboardPatient.dart';
import 'package:medical_app/features/messagerie/presentation/pages/MessageriePatient.dart';
import 'package:medical_app/features/notifications/presentation/pages/NotificationsPage.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilPatient.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousPatient.dart';

import '../../../../widgets/reusable_text_widget.dart';

class Homepatient extends StatefulWidget {
  const Homepatient({super.key});

  @override
  State<Homepatient> createState() => _HomepatientState();
}

class _HomepatientState extends State<Homepatient> {

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Rendez-vous"),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messagerie"),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profil"),
  ];
  List<Widget> pages = [
    Dashboardpatient(),
    RendezVousPatient(),
    MessageriePatient(),
    ProfilPatient(),
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

    );
  }
}

