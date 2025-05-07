import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../core/specialties.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../specialite/presentation/pages/AllSpecialtiesPage.dart';
import '../../domain/entities/rendez_vous_entity.dart';
import '../blocs/rendez-vous BLoC/rendez_vous_bloc.dart';
import '../../../../features/authentication/data/models/user_model.dart';
import '../../../../injection_container.dart' as di;
import 'appointment_details_page.dart';

class AppointmentsPatients extends StatefulWidget {
  const AppointmentsPatients({Key? key}) : super(key: key);

  @override
  _AppointmentsPatientsState createState() => _AppointmentsPatientsState();
}

class _AppointmentsPatientsState extends State<AppointmentsPatients> {
  late RendezVousBloc _rendezVousBloc;
  List<RendezVousEntity> appointments = [];
  UserModel? currentUser;
  bool isLoading = true;
  String? cancellingAppointmentId; // Track ID of appointment being cancelled

  @override
  void initState() {
    super.initState();
    _rendezVousBloc = di.sl<RendezVousBloc>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        currentUser = UserModel.fromJson(userMap);
        
        // Fetch appointments using the patient ID
        if (currentUser != null && currentUser!.id != null) {
          _rendezVousBloc.add(FetchRendezVous(patientId: currentUser!.id));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors du chargement des données de l'utilisateur",
              style: GoogleFonts.raleway(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fonction pour annuler un rendez-vous
  void _cancelAppointment(RendezVousEntity appointment) {
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
              if (appointment.id != null && 
                  appointment.patientId != null && 
                  appointment.doctorId != null && 
                  appointment.patientName != null && 
                  appointment.doctorName != null) {
                    
                setState(() {
                  cancellingAppointmentId = appointment.id; // Set the ID of the appointment being cancelled
                });
                
                _rendezVousBloc.add(UpdateRendezVousStatus(
                  rendezVousId: appointment.id!,
                  status: "cancelled",
                  patientId: appointment.patientId!,
                  doctorId: appointment.doctorId!,
                  patientName: appointment.patientName!,
                  doctorName: appointment.doctorName!,
                ));
              }
              Navigator.pop(context);
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

  // Navigate to appointment details
  void _navigateToAppointmentDetails(RendezVousEntity appointment) async {
    // Navigate to appointment details page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsPage(appointment: appointment),
      ),
    );
    
    // If the appointment was cancelled or modified from the details page, refresh the list
    if (result == true && currentUser != null && currentUser!.id != null) {
      _rendezVousBloc.add(FetchRendezVous(patientId: currentUser!.id));
    }
  }

  // Fonction pour ajouter un nouveau rendez-vous (à implémenter)
  void _addAppointment() {
    // Cette fonction serait implémentée pour ajouter un nouveau rendez-vous
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllSpecialtiesPage(specialties: specialtiesWithImages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _rendezVousBloc,
      child: BlocListener<RendezVousBloc, RendezVousState>(
        listener: (context, state) {
          if (state is RendezVousLoaded) {
            setState(() {
              appointments = state.rendezVous;
              isLoading = false;
            });
          } else if (state is RendezVousError) {
            setState(() {
              isLoading = false;
              cancellingAppointmentId = null; // Reset on error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.raleway(),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is RendezVousStatusUpdated) {
            setState(() {
              cancellingAppointmentId = null; // Reset after successful cancellation
            });
            
            // Reload appointments after status update
            if (currentUser != null && currentUser!.id != null) {
              _rendezVousBloc.add(FetchRendezVous(patientId: currentUser!.id));
            }
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
          }
        },
        child: Scaffold(
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
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                        : appointments.isEmpty
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
                            : RefreshIndicator(
                                onRefresh: () async {
                                  if (currentUser != null && currentUser!.id != null) {
                                    _rendezVousBloc.add(FetchRendezVous(patientId: currentUser!.id));
                                  }
                                },
                                color: AppColors.primaryColor,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(16.w),
                                  itemCount: appointments.length,
                                  itemBuilder: (context, index) {
                                    final appointment = appointments[index];
                                    final formattedDate =
                                        DateFormat('dd/MM/yyyy').format(appointment.startTime);
                                    final formattedTime =
                                        DateFormat('HH:mm').format(appointment.startTime);
                                    
                                    // Check if this appointment is currently being cancelled
                                    final isCancelling = cancellingAppointmentId == appointment.id;

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
                                                        appointment.doctorName != null
                                                            ? "Dr. ${appointment.doctorName?.split(" ").last ?? ''}"
                                                            : "Médecin à assigner",
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
                                                      SizedBox(height: 4.h),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                          vertical: 4.h,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _getStatusColor(appointment.status),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                          _getStatusText(appointment.status),
                                                          style: GoogleFonts.raleway(
                                                            fontSize: 12.sp,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      formattedDate,
                                                      style: GoogleFonts.raleway(
                                                        fontSize: 13.sp,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      formattedTime,
                                                      style: GoogleFonts.raleway(
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 16.h),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () => _navigateToAppointmentDetails(appointment),
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
                                                if (appointment.status != "cancelled")
                                                  isCancelling
                                                      ? Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                                          child: SizedBox(
                                                            height: 16.sp,
                                                            width: 16.sp,
                                                            child: CircularProgressIndicator(
                                                              color: Colors.red,
                                                              strokeWidth: 2.w,
                                                            ),
                                                          ),
                                                        )
                                                      : TextButton.icon(
                                                          onPressed: () => _cancelAppointment(appointment),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "accepted":
        return "Confirmé";
      case "pending":
        return "En attente";
      case "cancelled":
        return "Annulé";
      default:
        return "Inconnu";
    }
  }

  @override
  void dispose() {
    // Don't close bloc here as it might be used elsewhere and is being provided by dependency injection
    super.dispose();
  }
}
