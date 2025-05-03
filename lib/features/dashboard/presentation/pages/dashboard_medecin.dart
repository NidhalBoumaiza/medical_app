import 'package:flutter/material.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousMedecin.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/appointments_medecins.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../localisation/presentation/pages/pharmacie_page.dart';

class DashboardMedecin extends StatefulWidget {
  const DashboardMedecin({super.key});

  @override
  State<DashboardMedecin> createState() => _DashboardMedecinState();
}

class _DashboardMedecinState extends State<DashboardMedecin> {

  // Méthode pour construire un élément de rendez-vous
  Widget _buildAppointmentItem(String name, String description, String time, Color avatarColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  final List<Map<String, dynamic>> staticItems = [
    {'icon': Icons.people, 'text': 'Patients', 'color': Colors.blue},
    {'icon': Icons.calendar_today_outlined, 'text': 'Consultations', 'color': Colors.green},
    {'icon': Icons.medical_services, 'text': 'RDV', 'color': Colors.orange},
    {'icon': Icons.warning, 'text': 'Urgences', 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Statiques" Section
              const Text(
                'Statiques',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: staticItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      onTap: () {
                        switch (staticItems[index]["text"]) {
                          case 'Patients':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RendezVousMedecin()),
                            );
                            break;
                          case 'Consultations':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RendezVousMedecin()),
                            );
                            break;
                          case 'RDV':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PharmaciePage()),
                            );
                            break;
                          case 'Urgences':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PharmaciePage()),
                            );
                            break;
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              staticItems[index]['icon'],
                              size: 32,
                              color: staticItems[index]['color'],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              staticItems[index]['text'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Section "Prochains Rendez-vous"
              const SizedBox(height: 24),
              const Text(
                'Prochains Rendez-vous',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Liste des rendez-vous
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildAppointmentItem(
                          "Ahmed Ben Salah",
                          "Consultation normale",
                          "09:30",
                        AppColors.primaryColor,
                      ),
                      const Divider(),
                      _buildAppointmentItem(
                          "Fatma Karray",
                          "Suivi post-op",
                          "11:15",
                        AppColors.primaryColor,
                      ),
                      const Divider(),
                      _buildAppointmentItem(
                          "Mohamed Dridi",
                          "Première visite",
                          "14:00",
                        AppColors.primaryColor,
                      ),

                      // Bouton "Voir tous les rendez-vous"
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AppointmentsMedecins()),
                            );
                          },
                          child: Text(
                            "Voir tous les rendez-vous",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}