import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../features/authentication/data/models/user_model.dart';
import '../../../../features/authentication/data/models/medecin_model.dart';
import '../../../../features/authentication/domain/entities/medecin_entity.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/rendez_vous_entity.dart';
import '../blocs/rendez-vous BLoC/rendez_vous_bloc.dart';
import 'appointment_details_page.dart';

class AppointmentsMedecins extends StatefulWidget {
  final DateTime? initialSelectedDate;
  final String? initialFilter;

  const AppointmentsMedecins({
    Key? key, 
    this.initialSelectedDate,
    this.initialFilter,
  }) : super(key: key);

  @override
  _AppointmentsMedecinsState createState() => _AppointmentsMedecinsState();
}

class _AppointmentsMedecinsState extends State<AppointmentsMedecins> {
  late RendezVousBloc _rendezVousBloc;
  UserModel? currentUser;
  List<RendezVousEntity> appointments = [];
  List<RendezVousEntity> filteredAppointments = [];
  
  bool isLoading = true;
  String? updatingAppointmentId;
  DateTime? selectedDate;
  String? statusFilter;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _rendezVousBloc = di.sl<RendezVousBloc>();
    selectedDate = widget.initialSelectedDate;
    statusFilter = widget.initialFilter;
    _loadUser();
    
    // Debug the initial filter
    print('Initial status filter: ${widget.initialFilter}');
  }
  
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        setState(() {
          currentUser = UserModel.fromJson(userMap);
        });
        
        // Fetch appointments using the doctor ID
        if (currentUser != null && currentUser!.id != null) {
          _rendezVousBloc.add(FetchRendezVous(doctorId: currentUser!.id));
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
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

  // Function to filter appointments by date
  void _applyDateFilter() {
    filteredAppointments = List.from(appointments);
    
    print('Filtering ${appointments.length} appointments...');
    print('Current status filter: $statusFilter');
    
    // Apply date filter if selected
    if (selectedDate != null) {
      filteredAppointments = filteredAppointments.where((appointment) {
        final appointmentDate = DateFormat('yyyy-MM-dd').format(appointment.startTime);
        final filterDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        return appointmentDate == filterDate;
      }).toList();
      
      print('After date filter: ${filteredAppointments.length} appointments');
    }
    
    // Apply status filter if selected
    if (statusFilter != null && statusFilter!.isNotEmpty) {
      filteredAppointments = filteredAppointments.where((appointment) {
        final matches = appointment.status == statusFilter;
        print('Checking appointment ${appointment.id}: status=${appointment.status}, filter=$statusFilter, matches=$matches');
        return matches;
      }).toList();
      
      print('After status filter: ${filteredAppointments.length} appointments');
    }
  }

  // Reset filters
  void _resetFilter() {
    setState(() {
      selectedDate = null;
      statusFilter = null;
      filteredAppointments = List.from(appointments);
    });
  }
  
  void _applyStatusFilter(String status) {
    setState(() {
      statusFilter = status;
      _applyDateFilter();
    });
  }

  // Update appointment status
  void _updateAppointmentStatus(RendezVousEntity appointment, String newStatus) {
    if (appointment.id == null || 
        appointment.patientId == null || 
        appointment.doctorId == null || 
        appointment.patientName == null || 
        appointment.doctorName == null || 
        currentUser == null) {
      return;
    }
    
    setState(() {
      updatingAppointmentId = appointment.id;
    });
    
    _rendezVousBloc.add(UpdateRendezVousStatus(
      rendezVousId: appointment.id!,
      status: newStatus,
      patientId: appointment.patientId!,
      doctorId: appointment.doctorId!,
      patientName: appointment.patientName!,
      doctorName: appointment.doctorName!,
    ));
  }

  // Show time picker to change appointment time
  Future<void> _showTimePicker(RendezVousEntity appointment) async {
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(appointment.startTime);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context, 
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      // Create new appointment with updated time
      final DateTime newDateTime = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day,
        picked.hour,
        picked.minute,
      );
      
      // Calculate new end time based on doctor's appointment duration
      int appointmentDuration = 30; // Default
      if (currentUser != null && currentUser is MedecinModel) {
        appointmentDuration = (currentUser as MedecinModel).appointmentDuration;
      }
      
      final DateTime newEndTime = newDateTime.add(Duration(minutes: appointmentDuration));
      
      // Create new appointment object with updated time
      final updatedAppointment = RendezVousEntity(
        id: appointment.id,
        patientId: appointment.patientId,
        doctorId: appointment.doctorId,
        patientName: appointment.patientName,
        doctorName: appointment.doctorName,
        speciality: appointment.speciality,
        startTime: newDateTime,
        endTime: newEndTime,
        status: appointment.status,
      );
      
      // TODO: Add support for updating appointment time
      // For now show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "La fonctionnalité de modification d'heure sera disponible prochainement",
            style: GoogleFonts.raleway(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rendez-vous",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Calendar button for date selection
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2025),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primaryColor,
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  _applyDateFilter();
                });
              }
            },
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (currentUser != null && currentUser!.id != null) {
                _rendezVousBloc.add(FetchRendezVous(doctorId: currentUser!.id));
              }
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => _rendezVousBloc,
        child: BlocConsumer<RendezVousBloc, RendezVousState>(
          listener: (context, state) {
            if (state is RendezVousLoaded) {
              print('Loaded ${state.rendezVous.length} appointments');
              
              // Debug the appointments statuses
              for (var appt in state.rendezVous) {
                print('Appointment ${appt.id}: status=${appt.status}');
              }
              
              setState(() {
                appointments = state.rendezVous;
                isLoading = false;
                
                // Apply filters after setting appointments
                _applyDateFilter();
              });
              
              // Debug information about initial filters
              if (widget.initialFilter != null) {
                print('Initial filter was set: ${widget.initialFilter}');
                print('Current status filter: $statusFilter');
              }
              
              print('Filtered appointments count: ${filteredAppointments.length}');
            } else if (state is RendezVousStatusUpdated) {
              setState(() {
                updatingAppointmentId = null;
              });
              
              // Refresh appointments
              if (currentUser != null && currentUser!.id != null) {
                _rendezVousBloc.add(FetchRendezVous(doctorId: currentUser!.id));
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Statut du rendez-vous mis à jour avec succès",
                    style: GoogleFonts.raleway(),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else if (state is RendezVousError) {
              setState(() {
                isLoading = false;
                updatingAppointmentId = null;
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
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                if (selectedDate != null || statusFilter != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    color: AppColors.primaryColor.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded, 
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            selectedDate != null 
                                ? "Date: ${DateFormat('dd MMMM yyyy').format(selectedDate!)}" 
                                : statusFilter != null 
                                  ? "Statut: ${_getStatusText(statusFilter!)}" 
                                  : "Filtres",
                            style: GoogleFonts.raleway(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _resetFilter,
                          child: Icon(
                            Icons.close,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Status filter chips
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('Tous', null),
                      SizedBox(width: 8.w),
                      _buildFilterChip('En attente', 'pending'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Acceptés', 'accepted'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Terminés', 'completed'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Annulés', 'cancelled'),
                    ],
                  ),
                ),
                
                Expanded(
                  child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "Chargement des rendez-vous...",
                              style: GoogleFonts.raleway(
                                fontSize: 16.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredAppointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(24.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  size: 64.sp,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                selectedDate != null
                                  ? "Aucun rendez-vous trouvé pour cette date"
                                  : statusFilter != null
                                    ? "Aucun rendez-vous ${_getStatusText(statusFilter!).toLowerCase()}"
                                    : "Aucun rendez-vous trouvé",
                                style: GoogleFonts.raleway(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Essayez de modifier les filtres ou d'actualiser la page",
                                style: GoogleFonts.raleway(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (selectedDate != null || statusFilter != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 24.h),
                                  child: ElevatedButton.icon(
                                    onPressed: _resetFilter,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: Icon(Icons.filter_alt_off, size: 20.sp),
                                    label: Text(
                                      "Supprimer les filtres",
                                      style: GoogleFonts.raleway(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (currentUser != null && currentUser!.id != null) {
                                      _rendezVousBloc.add(FetchRendezVous(doctorId: currentUser!.id));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.grey[800],
                                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(Icons.refresh, size: 20.sp),
                                  label: Text(
                                    "Actualiser",
                                    style: GoogleFonts.raleway(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (currentUser != null && currentUser!.id != null) {
                              _rendezVousBloc.add(FetchRendezVous(doctorId: currentUser!.id));
                            }
                          },
                          color: AppColors.primaryColor,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: filteredAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = filteredAppointments[index];
                              final isUpdating = updatingAppointmentId == appointment.id;
                              final formattedDate = DateFormat('dd/MM/yyyy').format(appointment.startTime);
                              final formattedTime = DateFormat('HH:mm').format(appointment.startTime);
                              
                              return Card(
                                margin: EdgeInsets.only(bottom: 12.h),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: InkWell(
                                  onTap: appointment.id != null ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AppointmentDetailsPage(
                                          appointment: appointment,
                                        ),
                                      ),
                                    );
                                  } : null,
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 50.h,
                                              width: 50.w,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 30.sp,
                                              ),
                                            ),
                                            SizedBox(width: 16.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    appointment.patientName ?? "Patient inconnu",
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    "$formattedDate à $formattedTime",
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 14.sp,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 10.w,
                                                          vertical: 4.h,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _getStatusColor(appointment.status).withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(20.r),
                                                        ),
                                                        child: Text(
                                                          _getStatusText(appointment.status),
                                                          style: GoogleFonts.raleway(
                                                            fontSize: 12.sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: _getStatusColor(appointment.status),
                                                          ),
                                                        ),
                                                      ),
                                                      if (appointment.speciality != null)
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 8.w),
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: 10.w,
                                                              vertical: 4.h,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.blue.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(20.r),
                                                            ),
                                                            child: Text(
                                                              appointment.speciality!,
                                                              style: GoogleFonts.raleway(
                                                                fontSize: 12.sp,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.blue,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (appointment.status == "pending")
                                          Padding(
                                            padding: EdgeInsets.only(top: 16.h),
                                            child: Wrap(
                                              spacing: 8.w,
                                              runSpacing: 8.h,
                                              alignment: WrapAlignment.end,
                                              children: [
                                                OutlinedButton.icon(
                                                  onPressed: isUpdating ? null : () => _showTimePicker(appointment),
                                                  icon: Icon(
                                                    Icons.access_time,
                                                    size: 18.sp,
                                                    color: Colors.blue,
                                                  ),
                                                  label: Text(
                                                    "Modifier l'heure",
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 12.sp,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(color: Colors.blue.shade300),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 6.h,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: isUpdating ? null : () => _updateAppointmentStatus(appointment, "accepted"),
                                                  icon: isUpdating
                                                    ? SizedBox(
                                                        height: 16.sp,
                                                        width: 16.sp,
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.w,
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.check,
                                                        size: 18.sp,
                                                        color: Colors.white,
                                                      ),
                                                  label: Text(
                                                    "Accepter",
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 12.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 6.h,
                                                    ),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: isUpdating ? null : () => _updateAppointmentStatus(appointment, "cancelled"),
                                                  icon: Icon(
                                                    Icons.close,
                                                    size: 18.sp,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    "Refuser",
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 12.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 6.h,
                                                    ),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String? status) {
    final isSelected = status == statusFilter;
    
    return GestureDetector(
      onTap: () {
        print('Filter chip tapped: $label, status: $status');
        setState(() {
          statusFilter = status;
          _applyDateFilter();
        });
        print('After setting filter - statusFilter: $statusFilter');
        print('Filtered appointments: ${filteredAppointments.length}');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Accepté';
      case 'cancelled':
        return 'Annulé';
      case 'completed':
        return 'Terminé';
      default:
        return 'Inconnu';
    }
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

  @override
  void dispose() {
    super.dispose();
  }
}