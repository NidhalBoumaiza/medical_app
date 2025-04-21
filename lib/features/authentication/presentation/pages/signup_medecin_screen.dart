import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../domain/entities/medecin_entity.dart';
import '../../../../core/specialties.dart';
import 'password_screen.dart';

class SignupMedecinScreen extends StatefulWidget {
  final MedecinEntity medecinEntity;

  const SignupMedecinScreen({super.key, required this.medecinEntity});

  @override
  State<SignupMedecinScreen> createState() => _SignupMedecinScreenState();
}

class _SignupMedecinScreenState extends State<SignupMedecinScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController numLicenceController = TextEditingController();
  String? selectedSpecialty;

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
              'Inscription Médecin',
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
                      "Spécialité :",
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                        hintText: "Sélectionner une spécialité".tr,
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
                          return "Spécialité est obligatoire".tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      "Numéro de licence :",
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ReusableTextFieldWidget(
                      controller: numLicenceController,
                      fillColor: const Color(0xfffafcfc),
                      borderSide: const BorderSide(
                        color: Color(0xfff3f6f9),
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                      hintText: "Numéro de licence".tr,
                      keyboardType: TextInputType.text,
                      errorMessage: "Numéro de licence est obligatoire".tr,
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
                            final updatedMedecinEntity = MedecinEntity(
                              name: widget.medecinEntity.name,
                              lastName: widget.medecinEntity.lastName,
                              email: widget.medecinEntity.email,
                              role: widget.medecinEntity.role,
                              gender: widget.medecinEntity.gender,
                              phoneNumber: widget.medecinEntity.phoneNumber,
                              dateOfBirth: widget.medecinEntity.dateOfBirth,
                              speciality: selectedSpecialty!,
                              numLicence: numLicenceController.text,
                            );
                            Get.to(() => PasswordScreen(entity: updatedMedecinEntity));
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

  @override
  void dispose() {
    numLicenceController.dispose();
    super.dispose();
  }
}