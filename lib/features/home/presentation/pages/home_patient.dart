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
import '../../../payement/presentation/pages/payement.dart';
class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  int _selectedIndex = 0;

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_filled),
      label: 'Accueil',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Rendez-vous',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      activeIcon: Icon(Icons.chat_bubble),
      label: 'Messages',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  final List<Widget> _pages = [
    const Dashboardpatient(),
    const RendezVousPatient(),
    const MessageriePatient(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MediLink',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Badge(
              child: Icon(Icons.notifications_none, color: Colors.white),
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
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            items: _navItems,
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 10,
            selectedLabelStyle: const TextStyle(fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            onTap: _onItemTapped,
          ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
        backgroundColor: const Color(0xFF3F51B5),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Color(0xFF3F51B5)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'johndoe@example.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
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
                        MaterialPageRoute(builder: (context) => SecoursScreen()),
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
                        MaterialPageRoute(builder: (context) => const PaymentsPage()), // Corrected class name
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
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: _buildDrawerItem(
                icon: FontAwesomeIcons.rightFromBracket,
                title: 'Déconnexion',
                onTap: () {
                  // Add logout functionality
                },
                color: Colors.red,
              ),
            ),
          ],
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
      leading: Icon(icon, color: color, size: 24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (badgeCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Color(0xFF2fa7bb),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      minLeadingWidth: 24,
    );
  }
}