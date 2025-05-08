import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../features/authentication/data/models/user_model.dart';
import '../../../../features/authentication/domain/entities/medecin_entity.dart';
import '../../../../features/authentication/domain/entities/patient_entity.dart';
import '../../../../injection_container.dart' as di;
import '../../../ordonnance/presentation/pages/create_prescription_page.dart';
import '../../../ratings/domain/entities/doctor_rating_entity.dart';
import '../../../ratings/presentation/bloc/rating_bloc.dart';
import '../../domain/entities/rendez_vous_entity.dart';
import '../blocs/rendez-vous BLoC/rendez_vous_bloc.dart';
import 'doctor_profile_page.dart';
import 'patient_profile_page.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final RendezVousEntity appointment;

  const AppointmentDetailsPage({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late RendezVousBloc _rendezVousBloc;
  late RatingBloc _ratingBloc;
  UserModel? currentUser;
  bool isLoading = true;
  bool isCancelling = false;
  double _rating = 3.0; // Default rating
  final TextEditingController _commentController = TextEditingController();
  bool hasRatedAppointment = false;
  bool isAppointmentPast = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    
    _rendezVousBloc = di.sl<RendezVousBloc>();
    _ratingBloc = di.sl<RatingBloc>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        setState(() {
          currentUser = UserModel.fromJson(userMap);
          isLoading = false;
        });
        
        // Check if appointment is in the past based on endTime if available
        DateTime appointmentEndTime;
        if (widget.appointment.endTime != null) {
          appointmentEndTime = widget.appointment.endTime!;
        } else {
          // Fallback to estimated duration if endTime not available
          appointmentEndTime = widget.appointment.startTime.add(const Duration(minutes: 30));
        }
        
        setState(() {
          isAppointmentPast = DateTime.now().isAfter(appointmentEndTime);
        });
        
        // Load if user has already rated this appointment
        if (widget.appointment.id != null && 
            currentUser?.id != null && 
            currentUser?.role == 'patient' &&
            widget.appointment.status == 'completed') {
          _checkIfRatedAppointment();
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error loading user: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkIfRatedAppointment() {
    if (widget.appointment.id != null && 
        currentUser?.id != null && 
        currentUser?.role == 'patient' &&
        widget.appointment.status == 'completed') {
      _ratingBloc.add(CheckPatientRatedAppointment(
        patientId: currentUser!.id!,
        rendezVousId: widget.appointment.id!,
      ));
    }
  }

  // Function to cancel an appointment
  void _cancelAppointment() {
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
              if (widget.appointment.id != null && 
                  widget.appointment.patientId != null && 
                  widget.appointment.doctorId != null && 
                  widget.appointment.patientName != null && 
                  widget.appointment.doctorName != null) {
                    
                setState(() {
                  isCancelling = true;
                });
                
                _rendezVousBloc.add(UpdateRendezVousStatus(
                  rendezVousId: widget.appointment.id!,
                  status: "cancelled",
                  patientId: widget.appointment.patientId!,
                  doctorId: widget.appointment.doctorId!,
                  patientName: widget.appointment.patientName!,
                  doctorName: widget.appointment.doctorName!,
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

  // Function to submit a rating
  void _submitRating() {
    if (currentUser == null || 
        currentUser!.id == null || 
        widget.appointment.doctorId == null || 
        widget.appointment.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de soumettre l'évaluation, informations manquantes",
            style: GoogleFonts.raleway(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final rating = DoctorRatingEntity.create(
      doctorId: widget.appointment.doctorId!,
      patientId: currentUser!.id!,
      patientName: currentUser!.name + ' ' + currentUser!.lastName,
      rating: _rating,
      comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      rendezVousId: widget.appointment.id!,
    );

    _ratingBloc.add(SubmitDoctorRating(rating));
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

  // Calculate appointment duration in minutes
  String _getAppointmentDuration() {
    if (widget.appointment.endTime != null) {
      final duration = widget.appointment.endTime!.difference(widget.appointment.startTime);
      final minutes = duration.inMinutes;
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        if (remainingMinutes == 0) {
          return "$hours heure${hours > 1 ? 's' : ''}";
        } else {
          return "$hours heure${hours > 1 ? 's' : ''} $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}";
        }
      } else {
        return "$minutes minute${minutes > 1 ? 's' : ''}";
      }
    } else {
      // Default duration if endTime not available
      return "30 minutes";
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
          appointmentDuration: doctorData['appointmentDuration'] as int? ?? 30,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching doctor info: $e');
      return null;
    }
  }

  void _navigateToDoctorProfile() async {
    if (widget.appointment.doctorId == null) return;
    
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
    MedecinEntity? doctorEntity = await _fetchDoctorInfo(widget.appointment.doctorId!);
    
    // Dismiss loading indicator
    Navigator.pop(context);
    
    // If fetch failed, create a basic doctor entity with available info
    if (doctorEntity == null) {
      final doctorName = widget.appointment.doctorName ?? '';
      final nameArray = doctorName.split(' ');
      final firstName = nameArray.isNotEmpty ? nameArray[0] : '';
      final lastName = nameArray.length > 1 ? nameArray[1] : '';
      
      doctorEntity = MedecinEntity(
        id: widget.appointment.doctorId!,
        name: firstName,
        lastName: lastName, 
        email: "docteur@medical-app.com",
        speciality: widget.appointment.speciality,
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

  // Fetch patient info from Firestore
  Future<PatientEntity?> _fetchPatientInfo(String patientId) async {
    try {
      final patientDoc = await _firestore.collection('patients').doc(patientId).get();
      
      if (patientDoc.exists) {
        Map<String, dynamic> patientData = patientDoc.data() as Map<String, dynamic>;
        return PatientEntity(
          id: patientId,
          name: patientData['name'] ?? '',
          lastName: patientData['lastName'] ?? '',
          email: patientData['email'] ?? '',
          role: patientData['role'] ?? 'patient',
          gender: patientData['gender'] ?? 'unknown',
          phoneNumber: patientData['phoneNumber'] ?? '',
          dateOfBirth: patientData['dateOfBirth'] != null
              ? (patientData['dateOfBirth'] is Timestamp)
                  ? (patientData['dateOfBirth'] as Timestamp).toDate()
                  : DateTime.parse(patientData['dateOfBirth'])
              : null,
          antecedent: patientData['antecedent'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching patient info: $e');
      return null;
    }
  }

  void _navigateToPatientProfile() async {
    if (widget.appointment.patientId == null) return;
    
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
    
    // Try to fetch patient from Firestore
    PatientEntity? patientEntity = await _fetchPatientInfo(widget.appointment.patientId!);
    
    // Dismiss loading indicator
    Navigator.pop(context);
    
    // If fetch failed, create a basic patient entity with available info
    if (patientEntity == null) {
      final patientName = widget.appointment.patientName ?? '';
      final nameArray = patientName.split(' ');
      final firstName = nameArray.isNotEmpty ? nameArray[0] : '';
      final lastName = nameArray.length > 1 ? nameArray[1] : '';
      
      patientEntity = PatientEntity(
        id: widget.appointment.patientId!,
        name: firstName,
        lastName: lastName, 
        email: "patient@medical-app.com",
        role: 'patient',
        gender: 'unknown',
        phoneNumber: "+212 600000000",
        antecedent: "",
      );
    }
    
    // Now patientEntity is guaranteed to be non-null
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientProfilePage(
          patient: patientEntity!,
        ),
      ),
    );
  }
  
  void _createPrescription() async {
    if (widget.appointment.patientId == null) return;
    
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
    
    // Try to fetch patient from Firestore for medical history
    PatientEntity? patientEntity = await _fetchPatientInfo(widget.appointment.patientId!);
    
    // Dismiss loading indicator
    Navigator.pop(context);
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePrescriptionPage(
          appointment: widget.appointment,
          patient: patientEntity,
        ),
      ),
    );
    
    // If prescription was created successfully, refresh the appointment status
    if (result == true && widget.appointment.id != null) {
      _rendezVousBloc.add(FetchRendezVous(patientId: widget.appointment.patientId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RendezVousBloc>(
          create: (context) => _rendezVousBloc,
        ),
        BlocProvider<RatingBloc>(
          create: (context) => _ratingBloc,
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<RendezVousBloc, RendezVousState>(
            listener: (context, state) {
              if (state is RendezVousStatusUpdated) {
                setState(() {
                  isCancelling = false;
                });
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
                Navigator.pop(context, true); // Return true to indicate cancellation
              } else if (state is RendezVousError) {
                setState(() {
                  isCancelling = false;
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
          ),
          BlocListener<RatingBloc, RatingState>(
            listener: (context, state) {
              if (state is PatientRatingChecked) {
                setState(() {
                  hasRatedAppointment = state.hasRated;
                });
              } else if (state is RatingSubmitted) {
                setState(() {
                  hasRatedAppointment = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Évaluation soumise avec succès !",
                      style: GoogleFonts.raleway(),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else if (state is RatingError) {
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
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Détails du rendez-vous",
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 2,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Appointment card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Statut:",
                                      style: GoogleFonts.raleway(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(widget.appointment.status),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        _getStatusText(widget.appointment.status),
                                        style: GoogleFonts.raleway(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                Divider(height: 30.h, thickness: 1),
                                
                                // Doctor info
                                Text(
                                  "Médecin:",
                                  style: GoogleFonts.raleway(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Container(
                                      height: 60.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryColor.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: widget.appointment.doctorId != null ? _navigateToDoctorProfile : null,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 36.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: widget.appointment.doctorId != null ? _navigateToDoctorProfile : null,
                                            child: Text(
                                              widget.appointment.doctorName != null
                                                  ? "Dr. ${widget.appointment.doctorName}"
                                                  : "Médecin à assigner",
                                              style: GoogleFonts.raleway(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            widget.appointment.speciality ?? 'Spécialité non spécifiée',
                                            style: GoogleFonts.raleway(
                                              fontSize: 16.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                Divider(height: 30.h, thickness: 1),
                                
                                // Patient info (shown only for doctors)
                                if (currentUser?.role == 'doctor')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Patient:",
                                            style: GoogleFonts.raleway(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: _navigateToPatientProfile,
                                            icon: Icon(
                                              Icons.person,
                                              size: 18.sp,
                                              color: AppColors.primaryColor,
                                            ),
                                            label: Text(
                                              "Voir profil",
                                              style: GoogleFonts.raleway(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        widget.appointment.patientName ?? "Patient inconnu",
                                        style: GoogleFonts.raleway(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                    ],
                                  ),
                                
                                // Date and time information with better layout
                                Text(
                                  "Informations du rendez-vous:",
                                  style: GoogleFonts.raleway(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: AppColors.primaryColor,
                                            size: 24.sp,
                                          ),
                                          SizedBox(width: 12.w),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Date',
                                                style: GoogleFonts.raleway(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              Text(
                                                DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                                                    .format(widget.appointment.startTime),
                                                style: GoogleFonts.raleway(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: AppColors.primaryColor,
                                            size: 24.sp,
                                          ),
                                          SizedBox(width: 12.w),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Heure',
                                                style: GoogleFonts.raleway(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              Text(
                                                DateFormat('HH:mm').format(widget.appointment.startTime),
                                                style: GoogleFonts.raleway(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                "Durée: ${_getAppointmentDuration()}",
                                                style: GoogleFonts.raleway(
                                                  fontSize: 14.sp,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Cancel button (only show if not cancelled and not in the past)
                                if (widget.appointment.status != "cancelled" && !isAppointmentPast)
                                  Padding(
                                    padding: EdgeInsets.only(top: 24.h),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: isCancelling ? null : _cancelAppointment,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: EdgeInsets.symmetric(vertical: 14.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          disabledBackgroundColor: Colors.red.withOpacity(0.6),
                                          elevation: 2,
                                        ),
                                        icon: isCancelling 
                                            ? SizedBox(
                                                height: 20.sp, 
                                                width: 20.sp, 
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.w,
                                                ),
                                              )
                                            : Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.white,
                                                size: 22.sp,
                                              ),
                                        label: Text(
                                          isCancelling ? "Annulation en cours..." : "Annuler le rendez-vous",
                                          style: GoogleFonts.raleway(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Rating section (only show if appointment is in the past and status is accepted)
                        if (isAppointmentPast && widget.appointment.status == "accepted")
                          Padding(
                            padding: EdgeInsets.only(top: 24.h),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          hasRatedAppointment ? Icons.star : Icons.star_border,
                                          color: Colors.amber,
                                          size: 28.sp,
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          hasRatedAppointment
                                              ? "Votre évaluation a été soumise"
                                              : "Évaluer votre médecin",
                                          style: GoogleFonts.raleway(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    
                                    if (!hasRatedAppointment) ...[
                                      Text(
                                        "Comment s'est passé votre rendez-vous avec Dr. ${widget.appointment.doctorName}?",
                                        style: GoogleFonts.raleway(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Center(
                                        child: RatingBar.builder(
                                          initialRating: 3,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            setState(() {
                                              _rating = rating;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      
                                      TextField(
                                        controller: _commentController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: "Commentaire (optionnel)",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: AppColors.primaryColor),
                                          ),
                                          fillColor: Colors.grey[50],
                                          filled: true,
                                          contentPadding: EdgeInsets.all(16),
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      
                                      SizedBox(
                                        width: double.infinity,
                                        child: BlocBuilder<RatingBloc, RatingState>(
                                          builder: (context, state) {
                                            final isSubmitting = state is RatingLoading;
                                            
                                            return ElevatedButton(
                                              onPressed: isSubmitting ? null : _submitRating,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primaryColor,
                                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 2,
                                              ),
                                              child: isSubmitting
                                                  ? SizedBox(
                                                      height: 20.sp,
                                                      width: 20.sp,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.w,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Soumettre l'évaluation",
                                                      style: GoogleFonts.raleway(
                                                        color: Colors.white,
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                            );
                                          },
                                        ),
                                      ),
                                    ] else ...[
                                      Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green[600],
                                              size: 60.sp,
                                            ),
                                            SizedBox(height: 16.h),
                                            Text(
                                              "Merci pour votre évaluation!",
                                              style: GoogleFonts.raleway(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "Votre retour nous aide à améliorer nos services.",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.raleway(
                                                fontSize: 14.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
} 