import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/core/widgets/reusable_text_field_widget.dart';
import 'package:medical_app/injection_container.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';

import '../../../../core/specialties.dart';
import '../blocs/rendez-vous BLoC/rendez_vous_bloc.dart';
import 'available_doctor_screen.dart';
import 'package:intl/intl.dart';

class RendezVousPatient extends StatefulWidget {
  final String? selectedSpecialty;

  const RendezVousPatient({super.key, this.selectedSpecialty});

  @override
  State<RendezVousPatient> createState() => _RendezVousPatientState();
}

class _RendezVousPatientState extends State<RendezVousPatient> {
  final TextEditingController dateTimeController = TextEditingController();
  String? selectedSpecialty;
  DateTime? selectedDateTime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.selectedSpecialty != null &&
        specialties.contains(widget.selectedSpecialty)) {
      selectedSpecialty = widget.selectedSpecialty;
    }
  }

  @override
  void dispose() {
    dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.whiteColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
                onPrimary: AppColors.whiteColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dateTimeController.text = DateFormat('dd/MM/yyyy à HH:mm').format(selectedDateTime!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            "Rechercher une consultation",
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    
                    // Header image
                    Center(
                      child: Image.asset(
                        'assets/images/Consultation.png',
                        height: 200.h,
                        width: 200.w,
                      ),
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Title
                    Text(
                      "Trouver votre médecin",
                      style: GoogleFonts.raleway(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    // Subtitle
                    Text(
                      "Sélectionnez une spécialité et une date pour votre consultation",
                      style: GoogleFonts.raleway(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    SizedBox(height: 30.h),
                    
                    // Specialty selection
                    Text(
                      "Spécialité médicale",
                      style: GoogleFonts.raleway(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          hintText: "Choisir une spécialité",
                          hintStyle: GoogleFonts.raleway(
                            color: Colors.grey[400],
                            fontSize: 15.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.medical_services_outlined,
                            color: AppColors.primaryColor,
                            size: 22.sp,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryColor,
                        ),
                        value: selectedSpecialty,
                        items: specialties
                            .map((specialty) => DropdownMenuItem(
                                  value: specialty,
                                  child: Text(
                                    specialty,
                                    style: GoogleFonts.raleway(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSpecialty = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez sélectionner une spécialité";
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Date and time selection
                    Text(
                      "Date et heure souhaitées",
                      style: GoogleFonts.raleway(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 10.h),
                    
                    GestureDetector(
                      onTap: () => _selectDateTime(context),
                      child: AbsorbPointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: dateTimeController,
                            style: GoogleFonts.raleway(
                              fontSize: 15.sp,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              hintText: "Sélectionner la date et l'heure",
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                                fontSize: 15.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Veuillez sélectionner une date et une heure";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Search button
                    BlocBuilder<RendezVousBloc, RendezVousState>(
                      builder: (context, state) {
                        final isLoading = state is RendezVousLoading;
                        
                        return Container(
                          width: double.infinity,
                          height: 55.h,
                          margin: EdgeInsets.only(bottom: 30.h),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 2,
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (selectedDateTime != null) {
                                        final authLocalDataSource =
                                            sl<AuthLocalDataSource>();
                                        final user =
                                            await authLocalDataSource.getUser();
                                        final patientName =
                                            '${user.name} ${user.lastName}'
                                                .trim();

                                        navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                          context,
                                          AvailableDoctorsScreen(
                                            specialty: selectedSpecialty!,
                                            startTime: selectedDateTime!,
                                            patientId: user.id!,
                                            patientName: patientName,
                                          ),
                                        );
                                      } else {
                                        showErrorSnackBar(context, 
                                          "Veuillez sélectionner une date et une heure valides"
                                        );
                                      }
                                    }
                                  },
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 22.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        "Rechercher un médecin",
                                        style: GoogleFonts.raleway(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}