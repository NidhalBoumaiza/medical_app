import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_event.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_state.dart';
import 'package:medical_app/core/widgets/reusable_text_field_widget.dart';
import 'package:medical_app/injection_container.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';

import '../../../authentication/data/data sources/auth_local_data_source.dart';
import 'available_doctor_screen.dart';



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

  final List<String> specialties = [
    'Dentiste',
    'Pneumologue',
    'Dermatologue',
    'Nutritionniste',
    'Cardiologue',
    'Psychologue',
    'Médecin généraliste',
    'Neurologue',
    'Orthopédique',
    'Gynécologue',
    'Ophtalmologue',
    'Médecin esthétique',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select the specialty passed from Dashboardpatient
    if (widget.selectedSpecialty != null && specialties.contains(widget.selectedSpecialty)) {
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
          dateTimeController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text("Demander une consultation"),
          backgroundColor: const Color(0xFF2FA7BB),
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: BlocListener<RendezVousBloc, RendezVousState>(
          listener: (context, state) {
            if (state is RendezVousError) {
              showErrorSnackBar(context, state.message);
            } else if (state is RendezVousCreated) {
              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                context,
                AvailableDoctorsScreen(
                  specialty: selectedSpecialty!,
                  dateTime: selectedDateTime!,
                ),
              );
              showSuccessSnackBar(context, 'Consultation demandée avec succès');
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(50.w, 20.h, 50.w, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: ReusableTextWidget(
                        text: "Demander une consultation",
                        textSize: 100,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Image.asset(
                      'assets/images/Consultation.png',
                      height: 1000.h,
                      width: 900.w,
                    ),
                    SizedBox(height: 100.h),
                    // Specialty Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xfffafcfc),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 3,
                          ),
                        ),
                        hintText: "Sélectionner une spécialité",
                        hintStyle: GoogleFonts.raleway(
                          color: Colors.grey,
                          fontSize: 45.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: selectedSpecialty,
                      items: specialties
                          .map((specialty) => DropdownMenuItem(
                        value: specialty,
                        child: Text(
                          specialty,
                          style: GoogleFonts.raleway(
                            fontSize: 45.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
                    SizedBox(height: 20.h),
                    // Date and Time Picker
                    GestureDetector(
                      onTap: () => _selectDateTime(context),
                      child: AbsorbPointer(
                        child: ReusableTextFieldWidget(
                          fillColor: const Color(0xfffafcfc),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                          hintText: "Sélectionner la date et l'heure",
                          controller: dateTimeController,
                          keyboardType: TextInputType.datetime,
                          errorMessage: "La date et l'heure sont obligatoires",
                        ),
                      ),
                    ),
                    SizedBox(height: 70.h),
                    // Search Button
                    BlocBuilder<RendezVousBloc, RendezVousState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 200.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            onPressed: state is RendezVousLoading
                                ? null
                                : () async {
                              if (selectedSpecialty != null &&
                                  dateTimeController.text.isNotEmpty) {
                                if (selectedDateTime != null) {
                                  // Fetch authenticated user data
                                  final authLocalDataSource =
                                  sl<AuthLocalDataSource>();
                                  final user =
                                  await authLocalDataSource.getUser();
                                  final patientName =
                                  '${user.name} ${user.lastName}'
                                      .trim();

                                  // Create a RendezVousEntity
                                  final rendezVous = RendezVousEntity(
                                    patientId: user.id,
                                    patientName: patientName,
                                    speciality: selectedSpecialty!,
                                    startTime: selectedDateTime!,
                                    status: 'En attente',
                                  );
                                  context.read<RendezVousBloc>().add(
                                    CreateRendezVous(rendezVous),
                                  );
                                } else {
                                  showErrorSnackBar(context,
                                      "Format de date et heure invalide");
                                }
                              } else {
                                showErrorSnackBar(context,
                                    "Veuillez remplir tous les champs");
                              }
                            },
                            child: state is RendezVousLoading
                                ? const CircularProgressIndicator(
                              color: AppColors.whiteColor,
                            )
                                : ReusableTextWidget(
                              text: "Rechercher des médecins",
                              textSize: 55,
                              fontWeight: FontWeight.w900,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 80.h),
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