import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../core/widgets/reusable_text_field_widget.dart';


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
        backgroundColor: AppColors.whiteColor, // Couleur de fond de la page
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.h), // Hauteur de l'AppBar
          child: AppBar(
            backgroundColor: Colors.transparent, // AppBar transparente
            centerTitle: true, // Centrer le titre
            title: Text(
              'Inscription Médecin', // Titre de la page
              style: TextStyle(
                fontSize: 80.sp, // Taille de la police
                fontWeight: FontWeight.w800, // Poids de la police
                color: AppColors.primaryColor, // Couleur du texte
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor), // Icône de retour
              onPressed: () {
                Get.back(); // Retour à la page précédente
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
              padding: EdgeInsets.symmetric(horizontal: 50.h, vertical: 40.h), // Marge intérieure
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alignement des éléments à gauche
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
                    controller: nomController, // Contrôleur pour le champ Nom
                    hintText: "Nom".tr, // Texte d'indication
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
                    controller: prenomController, // Contrôleur pour le champ Prénom
                    hintText: "Prénom".tr,
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
                    controller: emailController, // Contrôleur pour le champ Email
                    hintText: "Email".tr,
                    keyboardType: TextInputType.emailAddress, // Type de clavier pour l'email
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
                    controller: specialiteController, // Contrôleur pour le champ Spécialité
                    hintText: "Spécialité".tr,
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
                    controller: numLicenceController, // Contrôleur pour le champ Numéro de licence
                    hintText: "Numéro de licence".tr,
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
                    controller: numTelController, // Contrôleur pour le champ Numéro de téléphone
                    hintText: "Numéro de téléphone".tr,
                    keyboardType: TextInputType.phone, // Type de clavier pour le téléphone
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

                      },
                      child: Text(
                        "S'inscrire".tr, // Texte du bouton
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