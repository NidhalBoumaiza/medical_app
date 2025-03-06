import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/reusable_text_field_widget.dart';


class SignupPatientScreen extends StatefulWidget {
  const SignupPatientScreen({super.key});

  @override
  State<SignupPatientScreen> createState() => _SignupPatientScreenState();
}

class _SignupPatientScreenState extends State<SignupPatientScreen> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController numTelController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController antecedentsController = TextEditingController();
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
            FocusScope.of(context).unfocus(); // Fermer le clavier
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.h, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulaire d'inscription pour les patients
                  Text(
                    "Nom :",
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ReusableTextFieldWidget(
                    controller: nomController,
                    hintText: "Nom".tr,
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
                    hintText: "Prénom".tr,
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
                    controller: birthdayController,
                    hintText: "Date de naissance".tr,
                    keyboardType: TextInputType.datetime,
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
                    controller: numTelController,
                    hintText: "Numéro de téléphone".tr,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    "Adresse :",
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ReusableTextFieldWidget(
                    controller: adresseController,
                    hintText: "Adresse".tr,
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    "Antécédents médicaux :",
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ReusableTextFieldWidget(
                    controller: antecedentsController,
                    hintText: "Antécédents médicaux".tr,
                    maxLines: 3,
                  ),
                  SizedBox(height: 100.h),
                  // Bouton "S'inscrire"
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
                        // Logique d'inscription pour les patients
                      },
                      child: Text(
                        "S'inscrire".tr,
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
    );
  }
}