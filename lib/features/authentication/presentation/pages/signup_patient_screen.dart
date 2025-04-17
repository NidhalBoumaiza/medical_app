import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../domain/entities/patient_entity.dart';
import 'password_screen.dart';

class SignupPatientScreen extends StatefulWidget {
  final PatientEntity patientEntity;

  const SignupPatientScreen({super.key, required this.patientEntity});

  @override
  State<SignupPatientScreen> createState() => _SignupPatientScreenState();
}

class _SignupPatientScreenState extends State<SignupPatientScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController antecedentsController = TextEditingController();

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
              'Inscription Patient',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Antécédents médicaux :",
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ReusableTextFieldWidget(
                      controller: antecedentsController,
                      fillColor: const Color(0xfffafcfc),
                      maxLines: 5,
                      minLines: 5,
                      borderSide: const BorderSide(
                        color: Color(0xfff3f6f9),
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                      hintText: "Antécédents médicaux".tr,
                      errorMessage: "Antécédents médicaux sont obligatoires".tr,
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
                            final updatedPatientEntity = PatientEntity(
                              name: widget.patientEntity.name,
                              lastName: widget.patientEntity.lastName,
                              email: widget.patientEntity.email,
                              role: widget.patientEntity.role,
                              gender: widget.patientEntity.gender,
                              phoneNumber: widget.patientEntity.phoneNumber,
                              dateOfBirth: widget.patientEntity.dateOfBirth,
                              antecedent: antecedentsController.text,
                            );
                            Get.to(() => PasswordScreen(entity: updatedPatientEntity));
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
            ),
          ),
        ),
      ),
    );
  }
}