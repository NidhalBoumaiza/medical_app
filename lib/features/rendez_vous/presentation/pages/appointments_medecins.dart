import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart'; // Assurez-vous que le chemin est correct

// Modèle de données pour un rendez-vous
class Appointment {
  final String id;
  final String patientName;
  final String date;
  String time; // Non-final pour permettre la modification
  String status; // "pending", "accepted", "rejected"

  Appointment({
    required this.id,
    required this.patientName,
    required this.date,
    required this.time,
    this.status = "pending",
  });

  // Formater l'heure au style "10h00"
  String get formattedTime => time.replaceAll(':', 'h');
}

class AppointmentsMedecins extends StatefulWidget {
  const AppointmentsMedecins({Key? key}) : super(key: key);

  @override
  _AppointmentsMedecinsState createState() => _AppointmentsMedecinsState();
}

class _AppointmentsMedecinsState extends State<AppointmentsMedecins> {
  // Liste fictive de rendez-vous
  List<Appointment> appointments = [
    Appointment(id: "1", patientName: "Jean Dupont", date: "2025-05-04", time: "10:00"),
    Appointment(id: "2", patientName: "Marie Curie", date: "2025-05-04", time: "11:30"),
    Appointment(id: "3", patientName: "Ahmed Benali", date: "2025-05-05", time: "14:00"),
  ];

  // Liste filtrée pour l'affichage
  List<Appointment> filteredAppointments = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    filteredAppointments = List.from(appointments); // Afficher tous les rendez-vous au départ
  }

  // Fonction pour mettre à jour le statut d'un rendez-vous
  void _updateAppointmentStatus(String id, String newStatus) {
    setState(() {
      final appointment = appointments.firstWhere((app) => app.id == id);
      appointment.status = newStatus;
      filteredAppointments = List.from(appointments); // Mettre à jour la liste filtrée
      if (selectedDate != null) {
        _applyDateFilter();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rendez-vous ${newStatus == 'accepted' ? 'accepté' : 'rejeté'}")),
    );
  }

  // Fonction pour filtrer les rendez-vous par date
  Future<void> _filterByDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _applyDateFilter();
      });
    }
  }

  // Appliquer le filtre par date
  void _applyDateFilter() {
    filteredAppointments = appointments.where((app) {
      return app.date ==
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
    }).toList();
  }

  // Fonction pour réinitialiser le filtre
  void _resetFilter() {
    setState(() {
      selectedDate = null;
      filteredAppointments = List.from(appointments);
    });
  }

  // Fonction pour afficher un TimePicker stylé
  Future<void> _editAppointmentTime(Appointment appointment) async {
    TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(appointment.time.split(':')[0]),
      minute: int.parse(appointment.time.split(':')[1]),
    );
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choisir une nouvelle heure",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Custom Time Picker
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Heures
                            SizedBox(
                              width: 80,
                              child: DropdownButton<int>(
                                value: selectedTime?.hour ?? initialTime.hour,
                                items: List.generate(24, (index) => index)
                                    .map((hour) => DropdownMenuItem(
                                  value: hour,
                                  child: Text(
                                    hour.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      selectedTime = TimeOfDay(
                                        hour: value,
                                        minute: selectedTime?.minute ?? initialTime.minute,
                                      );
                                    });
                                  }
                                },
                                isExpanded: true,
                                underline: Container(
                                  height: 2,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "h",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Minutes
                            SizedBox(
                              width: 80,
                              child: DropdownButton<int>(
                                value: selectedTime?.minute ?? initialTime.minute,
                                items: List.generate(60, (index) => index)
                                    .map((minute) => DropdownMenuItem(
                                  value: minute,
                                  child: Text(
                                    minute.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() {
                                      selectedTime = TimeOfDay(
                                        hour: selectedTime?.hour ?? initialTime.hour,
                                        minute: value,
                                      );
                                    });
                                  }
                                },
                                isExpanded: true,
                                underline: Container(
                                  height: 2,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (selectedTime != null) {
                          setState(() {
                            appointment.time =
                            "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                            filteredAppointments = List.from(appointments);
                            if (selectedDate != null) {
                              _applyDateFilter();
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Heure du rendez-vous modifiée")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Confirmer",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des Rendez-vous"),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.teal),
            onPressed: _filterByDate,
            tooltip: "Filtrer par date",
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: _resetFilter,
              tooltip: "Réinitialiser le filtre",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredAppointments.isEmpty
            ? const Center(child: Text("Aucun rendez-vous à afficher"))
            : ListView.builder(
          itemCount: filteredAppointments.length,
          itemBuilder: (context, index) {
            final appointment = filteredAppointments[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  appointment.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${appointment.date} à ${appointment.formattedTime}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton pour modifier l'heure
                    IconButton(
                      icon: const Icon(Icons.access_time, color: Colors.blue),
                      onPressed: () => _editAppointmentTime(appointment),
                      tooltip: "Modifier l'heure",
                    ),
                    // Afficher le statut ou les boutons selon l'état
                    if (appointment.status == "pending") ...[
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _updateAppointmentStatus(appointment.id, "accepted"),
                        tooltip: "Accepter",
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _updateAppointmentStatus(appointment.id, "rejected"),
                        tooltip: "Rejeter",
                      ),
                    ] else
                      Text(
                        appointment.status == "accepted" ? "Accepté" : "Rejeté",
                        style: TextStyle(
                          color: appointment.status == "accepted" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}