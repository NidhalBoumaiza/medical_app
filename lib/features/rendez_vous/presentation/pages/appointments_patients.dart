import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/rendez_vous_entity.dart';

class AppointmentsPatients extends StatefulWidget {
  const AppointmentsPatients({Key? key}) : super(key: key);

  @override
  _AppointmentsPatientsState createState() => _AppointmentsPatientsState();
}

class _AppointmentsPatientsState extends State<AppointmentsPatients> {
  // Simulation des données des rendez-vous (à remplacer par Firestore)
  List<RendezVousEntity> appointments = [
    RendezVousEntity.create(
      id: "1",
      patientId: "patient_001",
      doctorId: "doctor_001",
      patientName: "Jean Dupont",
      doctorName: "Dr. Martin",
      speciality: "Cardiologie",
      startTime: DateTime(2025, 1, 15, 10, 30),
      status: "accepted",
    ),
    RendezVousEntity.create(
      id: "2",
      patientId: "patient_001",
      doctorId: "doctor_002",
      patientName: "Jean Dupont",
      doctorName: "Dr. Leclerc",
      speciality: "Dermatologie",
      startTime: DateTime(2025, 2, 10, 14, 0),
      status: "pending",
    ),
    RendezVousEntity.create(
      id: "3",
      patientId: "patient_001",
      doctorId: "doctor_003",
      patientName: "Jean Dupont",
      doctorName: "Dr. Dubois",
      speciality: "Généraliste",
      startTime: DateTime(2025, 3, 5, 9, 0),
      status: "accepted",
    ),
  ];

  // Fonction pour annuler un rendez-vous
  void _cancelAppointment(String? id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer l'annulation"),
        content: const Text("Voulez-vous vraiment annuler ce rendez-vous ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                appointments.removeWhere((appointment) => appointment.id == id);
                // À remplacer par une mise à jour Firestore dans une vraie app
                // Exemple : await FirebaseFirestore.instance.collection('rendezvous').doc(id).delete();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Rendez-vous annulé avec succès !")),
              );
            },
            child: const Text("Oui"),
          ),
        ],
      ),
    );
  }

  // Fonction pour obtenir une couleur basée sur le statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade500;
      case 'pending':
        return Colors.orange.shade500;
      case 'refused':
        return Colors.red.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des Rendez-vous"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: appointments.isEmpty
          ? const Center(
        child: Text(
          "Aucun rendez-vous trouvé.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final formattedDate =
          DateFormat('dd/MM/yyyy').format(appointment.startTime);
          final formattedTime =
          DateFormat('HH:mm').format(appointment.startTime);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$formattedDate à $formattedTime",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (appointment.doctorName != null)
                          Text(
                            "Médecin : ${appointment.doctorName}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        if (appointment.speciality != null)
                          Text(
                            "Spécialité : ${appointment.speciality}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        Text(
                          "Statut : ${appointment.status}",
                          style: TextStyle(
                            fontSize: 16,
                            color: _getStatusColor(appointment.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _cancelAppointment(appointment.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
