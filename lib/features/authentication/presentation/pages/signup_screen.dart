import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:medical_app/cubit/toggle%20cubit/toggle_cubit.dart';
import 'package:medical_app/features/authentication/presentation/pages/signup_medecin_screen.dart';
import 'package:medical_app/features/authentication/presentation/pages/signup_patient_screen.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../domain/entities/medecin_entity.dart';
import '../../domain/entities/patient_entity.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController numTel = TextEditingController();
  late String gender = "Homme";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthdayController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.h),
          child: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              'Inscription',
              style: TextStyle(
                fontSize: 80.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryColor,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.h, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: BlocBuilder<ToggleCubit, ToggleState>(
                      builder: (context, state) {
                        return AnimatedToggleSwitch<bool>.dual(
                          current: state is PatientState,
                          first: true,
                          second: false,
                          spacing: 45.0,
                          animationDuration: const Duration(milliseconds: 600),
                          style: ToggleStyle(
                            borderColor: Colors.transparent,
                            indicatorColor: AppColors.primaryColor,
                            backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                          ),
                          customIconBuilder: (context, local, global) {
                            return Center(
                              child: Text(
                                state is PatientState ? "Patient" : "Médecin",
                                style: TextStyle(
                                  color: state is PatientState ? Colors.white : AppColors.whiteColor,
                                  fontSize: 35.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          onChanged: (bool value) {
                            context.read<ToggleCubit>().toggle();
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nom :",
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ReusableTextFieldWidget(
                          controller: nomController,
                          fillColor: const Color(0xfffafcfc),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                          hintText: "Nom".tr,
                          keyboardType: TextInputType.text,
                          errorMessage: "Nom est obligatoire".tr,
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Prénom :",
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ReusableTextFieldWidget(
                          controller: prenomController,
                          fillColor: const Color(0xfffafcfc),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                          hintText: "Prénom".tr,
                          keyboardType: TextInputType.text,
                          errorMessage: "Prénom est obligatoire".tr,
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Email :",
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ReusableTextFieldWidget(
                          controller: emailController,
                          fillColor: const Color(0xfffafcfc),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                          hintText: "Email".tr,
                          keyboardType: TextInputType.emailAddress,
                          errorMessage: "email est obligatoire".tr,
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Date de naissance :",
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: ReusableTextFieldWidget(
                              controller: birthdayController,
                              fillColor: const Color(0xfffafcfc),
                              borderSide: const BorderSide(
                                color: Color(0xfff3f6f9),
                                width: 3,
                                style: BorderStyle.solid,
                              ),
                              hintText: "Date de naissance".tr,
                              keyboardType: TextInputType.datetime,
                              errorMessage: "date de naissance est obligatoire".tr,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Genre :",
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        DropdownMenu<String>(
                          initialSelection: gender,
                          onSelected: (String? value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry<String>(
                              value: 'Homme',
                              label: 'Homme',
                            ),
                            DropdownMenuEntry<String>(
                              value: 'Femme',
                              label: 'Femme',
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Numéro de téléphone :",
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ReusableTextFieldWidget(
                          controller: numTel,
                          fillColor: const Color(0xfffafcfc),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                          hintText: "Numéro de téléphone".tr,
                          keyboardType: TextInputType.phone,
                          errorMessage: "Numéro de téléphone est obligatoire".tr,
                        ),
                        SizedBox(height: 100.h),
                        SizedBox(
                          width: double.infinity,
                          height: 200.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final dateOfBirth = _parseDate(birthdayController.text);
                                if (dateOfBirth == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Date de naissance invalide".tr)),
                                  );
                                  return;
                                }
                                if (context.read<ToggleCubit>().state is PatientState) {
                                  final patientEntity = PatientEntity(
                                    name: nomController.text,
                                    lastName: prenomController.text,
                                    email: emailController.text,
                                    role: 'patient',
                                    gender: gender,
                                    phoneNumber: numTel.text,
                                    dateOfBirth: dateOfBirth,
                                    antecedent: '',
                                  );
                                  Get.to(() => SignupPatientScreen(patientEntity: patientEntity));
                                } else {
                                  final medecinEntity = MedecinEntity(
                                    name: nomController.text,
                                    lastName: prenomController.text,
                                    email: emailController.text,
                                    role: 'medecin',
                                    gender: gender,
                                    phoneNumber: numTel.text,
                                    dateOfBirth: dateOfBirth,
                                    speciality: '',
                                    numLicence: '',
                                  );
                                  Get.to(() => SignupMedecinScreen(medecinEntity: medecinEntity));
                                }
                              }
                            },
                            child: Text(
                              "Suivant".tr,
                              style: GoogleFonts.raleway(
                                fontSize: 60.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                              ),
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
        ),
      ),
    );
  }
}