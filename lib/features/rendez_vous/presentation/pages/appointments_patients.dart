import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/specialties.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../authentication/domain/entities/medecin_entity.dart';
import '../../../specialite/presentation/pages/AllSpecialtiesPage.dart';
import '../../domain/entities/rendez_vous_entity.dart';
import '../blocs/rendez-vous BLoC/rendez_vous_bloc.dart';
import '../../../../features/authentication/data/models/user_model.dart';
import '../../../../injection_container.dart' as di;
import 'appointment_details_page.dart';
import 'doctor_profile_page.dart';

class AppointmentsPatients extends StatefulWidget {
  const AppointmentsPatients({Key? key}) : super(key: key);

  @override
  _AppointmentsPatientsState createState() => _AppointmentsPatientsState();
}

class _AppointmentsPatientsState extends State<AppointmentsPatients> {
  late RendezVousBloc _rendezVousBloc;
  List<RendezVousEntity> appointments = [];
  List<RendezVousEntity> filteredAppointments = [];
  UserModel? currentUser;
  bool isLoading = true;
  String? cancellingAppointmentId; // Track ID of appointment being cancelled
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Calendar related variables
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarVisible = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _rendezVousBloc = di.sl<RendezVousBloc>();
    _loadUser();
    
    // Set an initial selected day to today for better UX
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    
    print('AppointmentsPatients: initState called, _isCalendarVisible = $_isCalendarVisible');
  }

  // Make setState more verbose with logging
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    // Add a small delay to ensure the state is updated before logging
    Future.microtask(() {
      print('AppointmentsPatients: setState called, _isCalendarVisible = $_isCalendarVisible');
    });
  }

  Future<void> _loadUser() async {
    print('AppointmentsPatients: Loading user data...');
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        print('AppointmentsPatients: User JSON loaded: ${userMap['id']}');
        currentUser = UserModel.fromJson(userMap);
        
        // Fetch appointments using the patient ID
        if (currentUser != null && currentUser!.id != null) {
          print('AppointmentsPatients: Fetching appointments for patient ID: ${currentUser!.id}');
          
          // Check for past appointments that need to be updated to completed
          _rendezVousBloc.add(CheckAndUpdatePastAppointments(
            userId: currentUser!.id!,
            userRole: 'patient',
          ));
          
          // Then fetch the appointments (which will now have updated statuses)
          _rendezVousBloc.add(FetchRendezVous(patientId: currentUser!.id));
        } else {
          print('AppointmentsPatients: Current user or ID is null');
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('AppointmentsPatients: Error loading user data: $e');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors du chargement des données de l'utilisateur: $e",
              style: GoogleFonts.raleway(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      print('AppointmentsPatients: No user data found in SharedPreferences');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Filter appointments by selected date
  void _filterAppointmentsByDate(DateTime? selectedDay) {
    if (selectedDay == null) {
      setState(() {
        filteredAppointments = List.from(appointments);
      });
      return;
    }

    final filtered = appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day,
      );
      
      final selectedDate = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
      );
      
      return appointmentDate.isAtSameMomentAs(selectedDate);
    }).toList();

    setState(() {
      filteredAppointments = filtered;
    });
  }

  // Toggle calendar visibility
  void _toggleCalendar() {
    print('Toggling calendar visibility');
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  // Clear date filter
  void _clearDateFilter() {
    setState(() {
      _selectedDay = null;
      filteredAppointments = List.from(appointments);
    });
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
                  
                  // Optimistically update UI immediately
                  for (int i = 0; i < appointments.length; i++) {
                    if (appointments[i].id == appointment.id) {
                      final updatedAppointment = RendezVousEntity(
                        id: appointments[i].id,
                        patientId: appointments[i].patientId,
                        doctorId: appointments[i].doctorId,
                        patientName: appointments[i].patientName,
                        doctorName: appointments[i].doctorName,
                        speciality: appointments[i].speciality,
                        startTime: appointments[i].startTime,
                        endTime: appointments[i].endTime,
                        status: "cancelled", // Update status locally
                      );
                      appointments[i] = updatedAppointment;
                      break;
                    }
                  }
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
        builder: (context) => AppointmentDetailsPage(
          appointment: appointment,
          isDoctor: false, // Pass parameter to indicate this is a patient view
        ),
      ),
    );
    
    // If the appointment was cancelled or modified from the details page, refresh the list
    if (result == true && currentUser != null && currentUser!.id != null) {
      _rendezVousBloc.add(FetchRendezVous(patientId: currentUser!.id));
    }
  }

  // Fetch doctor info from Firestore
  Future<MedecinEntity?> _fetchDoctorInfo(String doctorId) async {
    try {
      final doctorDoc = await _firestore.collection('medecins').doc(doctorId).get();
      
      if (doctorDoc.exists) {
        Map<String, dynamic> doctorData = doctorDoc.data() as Map<String, dynamic>;
        return MedecinEntity(
          id: doctorId,
          name: doctorData['name'] ?? '',
          lastName: doctorData['lastName'] ?? '',
          email: doctorData['email'] ?? '',
          speciality: doctorData['speciality'],
          role: doctorData['role'] ?? 'doctor',
          gender: doctorData['gender'] ?? 'unknown',
          phoneNumber: doctorData['phoneNumber'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching doctor info: $e');
      return null;
    }
  }

  void _navigateToDoctorProfile(String? doctorId, String doctorName, String? speciality) async {
    if (doctorId == null) return;
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
    
    // Try to fetch doctor from Firestore
    MedecinEntity? doctorEntity = await _fetchDoctorInfo(doctorId);
    
    // Dismiss loading indicator
    Navigator.pop(context);
    
    // If fetch failed, create a basic doctor entity with available info
    if (doctorEntity == null) {
      final nameArray = doctorName.split(' ');
      final firstName = nameArray.isNotEmpty ? nameArray[0] : '';
      final lastName = nameArray.length > 1 ? nameArray[1] : '';
      
      doctorEntity = MedecinEntity(
        id: doctorId,
        name: firstName,
        lastName: lastName,
        email: "docteur@medical-app.com",
        speciality: speciality,
        role: 'doctor',
        gender: 'unknown',
        phoneNumber: "+212 600000000",
      );
    }
    
    // Now doctorEntity is guaranteed to be non-null
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorProfilePage(
          doctor: doctorEntity!,
          canBookAppointment: false,
        ),
      ),
    );
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
    print('Building AppointmentsPatients, filtered appointments: ${filteredAppointments.length}');
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppointment,
        backgroundColor: const Color(0xFFFF3B3B),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Mes rendez-vous",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            tooltip: "Filtrer par date",
            onPressed: _toggleCalendar,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            tooltip: "Prendre un rendez-vous",
            onPressed: _addAppointment,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: "Actualiser",
            onPressed: () {
              if (currentUser != null && currentUser!.id != null) {
                _rendezVousBloc.add(FetchRendezVous(patientId: currentUser!.id));
              }
            },
          ),
        ],
      ),
      body: BlocProvider.value(
        value: _rendezVousBloc,
      child: BlocListener<RendezVousBloc, RendezVousState>(
        listener: (context, state) {
            print('AppointmentsPatients: BlocListener received state: ${state.runtimeType}');
            
          if (state is RendezVousLoaded) {
              print('AppointmentsPatients: RendezVousLoaded state with ${state.rendezVous.length} appointments');
              
              // Debug each appointment
              for (var appt in state.rendezVous) {
                print('Appointment: id=${appt.id}, status=${appt.status}, doctor=${appt.doctorName}, time=${appt.startTime}');
              }
              
            setState(() {
              appointments = state.rendezVous;
                filteredAppointments = state.rendezVous; // Initialize filtered list with all appointments
              isLoading = false;
                
                // Apply date filter if a date is selected
                if (_selectedDay != null) {
                  _filterAppointmentsByDate(_selectedDay);
                }
            });
          } else if (state is RendezVousError) {
              print('AppointmentsPatients: RendezVousError state: ${state.message}');
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
            } else if (state is RendezVousLoading) {
              print('AppointmentsPatients: RendezVousLoading state');
              setState(() {
                isLoading = true;
              });
          } else if (state is RendezVousStatusUpdated) {
            setState(() {
              cancellingAppointmentId = null; // Reset after successful cancellation
            });
            
              // Show success message but don't reload - we've already updated the UI optimistically
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
          child: SafeArea(
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
                        "Chargement de vos rendez-vous...",
                        style: GoogleFonts.raleway(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Slide down calendar
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _isCalendarVisible ? 350.h : 0,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isCalendarVisible)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
            child: Column(
              children: [
                                    // Calendar header
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Sélectionner une date",
                                          style: GoogleFonts.raleway(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            if (_selectedDay != null)
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedDay = null;
                                                    _isCalendarVisible = false;
                                                  });
                                                  _filterAppointmentsByDate(null);
                                                },
                                                child: Text(
                                                  "Effacer",
                                                  style: GoogleFonts.raleway(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                setState(() {
                                                  _isCalendarVisible = false;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    
                                    // Table Calendar
                                    TableCalendar(
                                      firstDay: DateTime.now().subtract(Duration(days: 365)),
                                      lastDay: DateTime.now().add(Duration(days: 365)),
                                      focusedDay: _selectedDay ?? _focusedDay,
                                      calendarFormat: _calendarFormat,
                                      onFormatChanged: (format) {
                                        setState(() {
                                          _calendarFormat = format;
                                        });
                                      },
                                      selectedDayPredicate: (day) {
                                        return _selectedDay != null && isSameDay(_selectedDay!, day);
                                      },
                                      onDaySelected: (selectedDay, focusedDay) {
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                          _isCalendarVisible = false;
                                        });
                                        _filterAppointmentsByDate(_selectedDay);
                                      },
                                      // Custom marker builder to show appointment count
                                      calendarBuilders: CalendarBuilders(
                                        markerBuilder: (context, date, events) {
                                          // Count appointments on this day
                                          final appointmentsOnDay = appointments.where((appointment) {
                                            return isSameDay(appointment.startTime, date);
                                          }).toList();
                                          
                                          if (appointmentsOnDay.isEmpty) {
                                            return null;
                                          }
                                          
                                          return Positioned(
                                            bottom: 1,
                                            right: 1,
                  child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primaryColor,
                                              ),
                                              width: 16.w,
                                              height: 16.h,
                                              child: Center(
                                                child: Text(
                                                  '${appointmentsOnDay.length}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      calendarStyle: CalendarStyle(
                                        todayDecoration: BoxDecoration(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        selectedDecoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      headerStyle: HeaderStyle(
                                        formatButtonTextStyle: GoogleFonts.raleway(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                        titleTextStyle: GoogleFonts.raleway(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primaryColor),
                                        rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primaryColor),
                                        formatButtonVisible: true,
                                        titleCentered: true,
                                      ),
                                      availableCalendarFormats: const {
                                        CalendarFormat.month: 'Mois',
                                        CalendarFormat.twoWeeks: '2 Semaines',
                                        CalendarFormat.week: 'Semaine',
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Date filter indicator and clear button
                    if (_selectedDay != null)
                      Container(
                        color: Colors.grey[50],
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Row(
                          children: [
                            Icon(Icons.filter_list, color: AppColors.primaryColor, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              "Filtré par date: ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}",
                              style: GoogleFonts.raleway(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDay = null;
                                });
                                _filterAppointmentsByDate(null);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close, size: 18.sp, color: AppColors.primaryColor),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "Effacer",
                                    style: GoogleFonts.raleway(
                                      fontSize: 14.sp,
                              color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Display filteredAppointments instead of appointments
                    Expanded(
                      child: filteredAppointments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                  size: 64.sp,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                SizedBox(height: 24.h),
                                    Text(
                                  _selectedDay != null
                                      ? "Aucun rendez-vous pour le ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}"
                                      : "Aucun rendez-vous trouvé",
                                      style: GoogleFonts.raleway(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                                  child: Text(
                                    "Appuyez sur le bouton + pour prendre un rendez-vous avec un médecin",
                                    style: GoogleFonts.raleway(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                ElevatedButton.icon(
                                  onPressed: _addAppointment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(Icons.add, size: 20.sp),
                                  label: Text(
                                    "Prendre un rendez-vous",
                                      style: GoogleFonts.raleway(
                                        fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                              itemCount: filteredAppointments.length,
                                  itemBuilder: (context, index) {
                                final appointment = filteredAppointments[index];
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
                                                  child: InkWell(
                                                    onTap: () => _navigateToDoctorProfile(
                                                      appointment.doctorId,
                                                      appointment.doctorName ?? "Médecin",
                                                      appointment.speciality,
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      InkWell(
                                                        onTap: () => _navigateToDoctorProfile(
                                                          appointment.doctorId,
                                                          appointment.doctorName ?? "Médecin",
                                                          appointment.speciality,
                                                        ),
                                                        child: Text(
                                                          appointment.doctorName != null
                                                              ? "Dr. ${appointment.doctorName?.split(" ").last ?? ''}"
                                                              : "Médecin à assigner",
                                                          style: GoogleFonts.raleway(
                                                            fontSize: 15.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black87,
                                                          ),
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
      case "completed":
        return Colors.blue;
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
      case "completed":
        return "Terminé";
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

