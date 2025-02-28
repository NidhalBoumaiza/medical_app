import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/widgets/reusable_text_field_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPatient = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController numTel = TextEditingController();
  late String gender = "Homme";

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
              'Sign Up',
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
            FocusScope.of(
              context,
            ).unfocus(); // on l'utilise pour enlever le clavier
          },
          child: SingleChildScrollView(
            // pour scroller la page
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.h, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  Form(
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

                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "prenom :",
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

                          hintText: "prenom".tr,

                          keyboardType: TextInputType.emailAddress,
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
                          controller: nomController,
                          fillColor: const Color(0xfffafcfc),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),

                          hintText: "Email".tr,

                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Date de naissance :",
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

                          hintText: "Date de naissance".tr,

                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "gender :",
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        DropdownMenu<String>(
                          initialSelection: gender ?? 'Homme',
                          // Set initial value
                          onSelected: (String? value) {
                            setState(() {
                              gender =
                                  value!; // Update state when a value is selected
                            });
                          },
                          dropdownMenuEntries: [
                            const DropdownMenuEntry<String>(
                              value: 'Homme',
                              label: 'Homme',
                            ),
                            const DropdownMenuEntry<String>(
                              value: 'Femme',
                              label: 'Femme',
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Numéro de telephone :",
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

                          hintText: "Numéro de telephone".tr,

                          keyboardType: TextInputType.emailAddress,
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
                              // Get.updateLocale(Locale('fr', 'FR'));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Suivant".tr, // Translated text
                                  style: GoogleFonts.raleway(
                                    fontSize: 60.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ],
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

// Center(
// child: AnimatedToggleSwitch<bool>.dual(
// current: _isPatient,
// // Initial value: true for "patient"
// first: true,
// // Represents "patient"
// second: false,
// // Represents "médecin"
// spacing: 45.0,
// // Space between the labels
// animationDuration: const Duration(milliseconds: 600),
// // Smooth animation
// style: ToggleStyle(
// borderColor: Colors.transparent, // No border
// indicatorColor: Colors.blue, // Blue color for the indicator
// backgroundColor:
// Colors.blue.shade100, // Light blue background
// ),
// customIconBuilder: (context, local, global) {
// return Center(
// child: Text(
// _isPatient ? 'Patient' : 'Médecin',
// // Display labels based on state
// style: TextStyle(
// color: _isPatient ? Colors.white : Colors.blue,
// // White for patient, blue for médecin
// fontSize: 16.0,
// fontWeight: FontWeight.bold,
// ),
// ),
// );
// },
// onChanged: (bool value) {
// setState(() {
// _isPatient = value; // Update state when toggled
// });
// },
// ),
// ),
