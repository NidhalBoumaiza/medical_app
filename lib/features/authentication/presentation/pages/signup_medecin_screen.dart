import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';

class SignupMedecinScreen extends StatefulWidget {
  const SignupMedecinScreen({super.key});

  @override
  State<SignupMedecinScreen> createState() => _SignupMedecinScreenState();
}

class _SignupMedecinScreenState extends State<SignupMedecinScreen> {
  // Contrôleurs pour les champs de texte
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController specialiteController = TextEditingController();
  final TextEditingController numLicenceController = TextEditingController();
  final TextEditingController numTelController = TextEditingController();
  late String gender = "Homme"; // Variable pour stocker le genre sélectionné

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
            FocusScope.of(context).unfocus(); // Fermer le clavier lorsqu'on clique hors des champs
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.h, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ pour le nom
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
                  SizedBox(height: 30.h), // Espacement entre les champs

                  // Champ pour le prénom
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

                  // Champ pour l'email
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
                    errorMessage: "Email est obligatoire".tr,
                  ),
                  SizedBox(height: 30.h),

                  // Champ pour la spécialité
                  Text(
                    "Spécialité :",
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ReusableTextFieldWidget(
                    controller: specialiteController,
                    fillColor: const Color(0xfffafcfc),
                    borderSide: const BorderSide(
                      color: Color(0xfff3f6f9),
                      width: 3,
                      style: BorderStyle.solid,
                    ),
                    hintText: "Spécialité".tr,
                    keyboardType: TextInputType.text,
                    errorMessage: "Spécialité est obligatoire".tr,
                  ),
                  SizedBox(height: 30.h),

                  // Champ pour le numéro de licence
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
                  SizedBox(height: 30.h),

                  // Champ pour le numéro de téléphone
                  Text(
                    "Numéro de téléphone :",
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ReusableTextFieldWidget(
                    controller: numTelController,
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

                  // Bouton "S'inscrire"
                  SizedBox(
                    width: double.infinity, // Largeur maximale
                    height: 200.h, // Hauteur du bouton
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor, // Couleur de fond du bouton
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r), // Bordure arrondie
                        ),
                      ),
                      onPressed: () {
                        // Logique d'inscription
                      },
                      child: Text(
                        "S'inscrire".tr,
                        style: GoogleFonts.raleway(
                          fontSize: 60.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.whiteColor, // Couleur du texte
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