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
import '../../../ordonnance/domain/entities/prescription_entity.dart';
import '../../../ordonnance/presentation/bloc/prescription_bloc.dart';
import '../../../ordonnance/presentation/pages/prescription_details_page.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final RendezVousEntity appointment;
  final bool isDoctor;

  const AppointmentDetailsPage({
    Key? key,
    required this.appointment,
    this.isDoctor = false,
  }) : super(key: key);

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late RendezVousBloc _rendezVousBloc;
  late RatingBloc _ratingBloc;
  late PrescriptionBloc _prescriptionBloc;
  UserModel? currentUser;
  bool isLoading = true;
  bool isCancelling = false;
  double _rating = 3.0; // Default rating
  final TextEditingController _commentController = TextEditingController();
  bool hasRatedAppointment = false;
  bool isAppointmentPast = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Variables to store appointment rating data
  bool _isLoadingRating = false;
  DoctorRatingEntity? _appointmentRating;
  
  // Add these variables for prescription
  bool _isLoadingPrescription = false;
  PrescriptionEntity? _appointmentPrescription;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    
    _rendezVousBloc = di.sl<RendezVousBloc>();
    _ratingBloc = di.sl<RatingBloc>();
    _prescriptionBloc = di.sl<PrescriptionBloc>();
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
        
        // Check and update past appointments
        if (currentUser?.id != null) {
          _rendezVousBloc.add(CheckAndUpdatePastAppointments(
            userId: currentUser!.id!,
            userRole: currentUser!.role,
          ));
        }
        
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
        
        // If this is a doctor viewing a completed appointment, fetch its rating
        if (widget.appointment.id != null && 
            currentUser?.role == 'medecin' &&
            widget.appointment.status == 'completed') {
          _fetchAppointmentRating();
        }
        
        // Check if appointment has prescription
        if (widget.appointment.id != null) {
          _fetchAppointmentPrescription();
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
      case "completed":
        return "Terminé";
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
      case "completed":
        return Colors.blue;
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

  // Fetch appointment rating and comment
  Future<void> _fetchAppointmentRating() async {
    if (widget.appointment.id == null) return;
    
    setState(() {
      _isLoadingRating = true;
    });
    
    try {
      final ratingDoc = await _firestore
          .collection('ratings')
          .where('rendezVousId', isEqualTo: widget.appointment.id)
          .limit(1)
          .get();
      
      if (ratingDoc.docs.isNotEmpty) {
        final data = ratingDoc.docs.first.data();
        setState(() {
          _appointmentRating = DoctorRatingEntity(
            id: ratingDoc.docs.first.id,
            doctorId: data['doctorId'] ?? '',
            patientId: data['patientId'] ?? '',
            patientName: data['patientName'],
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            comment: data['comment'],
            createdAt: (data['createdAt'] is Timestamp) 
                ? (data['createdAt'] as Timestamp).toDate() 
                : DateTime.now(),
            rendezVousId: data['rendezVousId'] ?? '',
          );
        });
      }
    } catch (e) {
      print('Error fetching appointment rating: $e');
    } finally {
      setState(() {
        _isLoadingRating = false;
      });
    }
  }

  // Add this method to fetch prescription
  void _fetchAppointmentPrescription() {
    if (widget.appointment.id == null) return;
    
    setState(() {
      _isLoadingPrescription = true;
    });
    
    _prescriptionBloc.add(GetPrescriptionByAppointmentId(
      appointmentId: widget.appointment.id!,
    ));
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
        BlocProvider<PrescriptionBloc>(
          create: (context) => _prescriptionBloc,
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
          // Add PrescriptionBloc listener
          BlocListener<PrescriptionBloc, PrescriptionState>(
            listener: (context, state) {
              if (state is PrescriptionLoaded) {
                setState(() {
                  _appointmentPrescription = state.prescription;
                  _isLoadingPrescription = false;
                });
              } else if (state is PrescriptionNotFound) {
                setState(() {
                  _appointmentPrescription = null;
                  _isLoadingPrescription = false;
                });
              } else if (state is PrescriptionError) {
                setState(() {
                  _isLoadingPrescription = false;
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
          floatingActionButton: null,
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
                                if (currentUser?.role == 'medecin')
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
                        
                        // Always show prescription section for doctors, or show only for completed/past appointments for patients
                        if (currentUser?.role == 'medecin' || 
                            widget.appointment.status == 'completed' || 
                            (widget.appointment.status == 'accepted' && isAppointmentPast))
                          _buildPrescriptionSection(),
                        
                        // Only show rating section when it's not a doctor view and appointment is completed
                        if (!widget.isDoctor && 
                            widget.appointment.status == 'completed' && 
                            isAppointmentPast && 
                            currentUser?.role == 'patient')
                          _buildRatingSection(),
                          
                        // Show rating from patient when doctor is viewing a completed appointment
                        if (widget.isDoctor && 
                            widget.appointment.status == 'completed' && 
                            isAppointmentPast && 
                            currentUser?.role == 'medecin')
                          _buildDoctorViewRatingSection(),

                        // Add a prominent Add Prescription button for doctors
                        _buildAddPrescriptionButton(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // Extract rating section to a separate method
  Widget _buildRatingSection() {
    return Container(
      // Rating container implementation
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Évaluer le médecin",
            style: GoogleFonts.raleway(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 36.sp,
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
          SizedBox(height: 16.h),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ajoutez un commentaire (optionnel)',
              hintStyle: GoogleFonts.raleway(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: ElevatedButton(
              onPressed: hasRatedAppointment ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasRatedAppointment ? Colors.grey : AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                hasRatedAppointment ? "Déjà évalué" : "Soumettre l'évaluation",
                style: GoogleFonts.raleway(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section for doctors to view ratings left by patients
  Widget _buildDoctorViewRatingSection() {
    if (_isLoadingRating) {
      return Container(
        margin: EdgeInsets.only(top: 24.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              SizedBox(height: 12.h),
              Text(
                "Chargement de l'évaluation...",
                style: GoogleFonts.raleway(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Évaluation du patient",
            style: GoogleFonts.raleway(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          
          if (_appointmentRating != null) ...[
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 18.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8.w),
                Text(
                  _appointmentRating!.patientName ?? "Patient",
                  style: GoogleFonts.raleway(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < _appointmentRating!.rating.floor() 
                        ? Icons.star 
                        : (index < _appointmentRating!.rating 
                            ? Icons.star_half 
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 24.sp,
                  );
                }),
                SizedBox(width: 8.w),
                Text(
                  _appointmentRating!.rating.toString(),
                  style: GoogleFonts.raleway(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (_appointmentRating!.comment != null && _appointmentRating!.comment!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                "Commentaire:",
                style: GoogleFonts.raleway(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  _appointmentRating!.comment!,
                  style: GoogleFonts.raleway(
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Text(
              "Évalué le ${DateFormat('dd/MM/yyyy').format(_appointmentRating!.createdAt)}",
              style: GoogleFonts.raleway(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.star_border,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Pas encore d'évaluation",
                    style: GoogleFonts.raleway(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Le patient n'a pas encore évalué ce rendez-vous",
                    style: GoogleFonts.raleway(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Add the prescription section widget
  Widget _buildPrescriptionSection() {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ordonnance",
                style: GoogleFonts.raleway(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          if (_isLoadingPrescription)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 8.h),
                  Text(
                    "Chargement...",
                    style: GoogleFonts.raleway(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          else if (_appointmentPrescription != null)
            // Prescription exists
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<PrescriptionBloc>.value(
                            value: _prescriptionBloc,
                            child: PrescriptionDetailsPage(
                              prescription: _appointmentPrescription!,
                              isDoctor: currentUser?.role == 'medecin',
                            ),
                          ),
                        ),
                      ).then((_) {
                        // Refresh prescription data when returning
                        _fetchAppointmentPrescription();
                      });
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medical_services,
                                color: AppColors.primaryColor,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Ordonnance du ${DateFormat('dd/MM/yyyy').format(_appointmentPrescription!.date)}',
                                  style: GoogleFonts.raleway(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.medication,
                                color: Colors.grey[600],
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${_appointmentPrescription!.medications.length} médicament${_appointmentPrescription!.medications.length > 1 ? 's' : ''}',
                                style: GoogleFonts.raleway(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Voir détails',
                                style: GoogleFonts.raleway(
                                  fontSize: 14.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.primaryColor,
                                size: 20.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // No prescription
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    currentUser?.role == 'medecin'
                        ? "Aucune ordonnance créée pour ce rendez-vous"
                        : "Aucune ordonnance disponible pour ce rendez-vous",
                    style: GoogleFonts.raleway(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Add a prominent Add Prescription button for doctors
  Widget _buildAddPrescriptionButton() {
    if (currentUser?.role != 'medecin') {
      return SizedBox.shrink();
    }
    
    return Container(
      margin: EdgeInsets.only(top: 24.h, bottom: 24.h),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _appointmentPrescription == null
            ? _createPrescription
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePrescriptionPage(
                      appointment: widget.appointment,
                      existingPrescription: _appointmentPrescription,
                    ),
                  ),
                ).then((result) {
                  if (result == true) {
                    _fetchAppointmentPrescription();
                  }
                });
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        icon: Icon(
          _appointmentPrescription == null ? Icons.add : Icons.edit,
          color: Colors.white,
          size: 24.sp,
        ),
        label: Text(
          _appointmentPrescription == null ? "Créer une ordonnance" : "Modifier l'ordonnance",
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
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