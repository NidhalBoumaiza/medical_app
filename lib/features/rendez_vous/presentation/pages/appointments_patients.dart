import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
          "Confirmer l'annulation",
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          "Voulez-vous vraiment annuler ce rendez-vous ?",
          style: GoogleFonts.raleway(fontSize: 14.sp),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Non",
              style: GoogleFonts.raleway(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                appointments.removeWhere((appointment) => appointment.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Rendez-vous annulé avec succès !",
                    style: GoogleFonts.raleway(),
                  ),
                  backgroundColor: AppColors.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(
              "Oui",
              style: GoogleFonts.raleway(
                fontSize: 14.sp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour ajouter un nouveau rendez-vous (à implémenter)
  void _addAppointment() {
    // Cette fonction serait implémentée pour ajouter un nouveau rendez-vous
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Fonctionnalité d'ajout de rendez-vous en développement",
          style: GoogleFonts.raleway(),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        backgroundColor: const Color(0xFFFF3B3B),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: appointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 50.sp,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "Aucun rendez-vous trouvé",
                              style: GoogleFonts.raleway(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Appuyez sur + pour ajouter un rendez-vous",
                              style: GoogleFonts.raleway(
                                fontSize: 14.sp,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          final formattedDate =
                              DateFormat('dd/MM/yyyy').format(appointment.startTime);

                          return Card(
                            margin: EdgeInsets.only(bottom: 16.h),
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40.h,
                                        width: 40.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 24.sp,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Dr. ${appointment.doctorName?.split(" ").last ?? ''}",
                                              style: GoogleFonts.raleway(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              appointment.speciality ?? '',
                                              style: GoogleFonts.raleway(
                                                fontSize: 13.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.raleway(
                                          fontSize: 13.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          // Show appointment details
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Affichage des détails du rendez-vous",
                                                style: GoogleFonts.raleway(),
                                              ),
                                              backgroundColor: AppColors.primaryColor,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.calendar_today_outlined,
                                          color: AppColors.primaryColor,
                                          size: 16.sp,
                                        ),
                                        label: Text(
                                          "Voir les détails",
                                          style: GoogleFonts.raleway(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      TextButton.icon(
                                        onPressed: () => _cancelAppointment(appointment.id),
                                        icon: Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.red,
                                          size: 16.sp,
                                        ),
                                        label: Text(
                                          "Annuler RDV",
                                          style: GoogleFonts.raleway(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
