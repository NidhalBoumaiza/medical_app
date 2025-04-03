import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/authentication/domain/usecases/signup_screen.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../../../widgets/reusable_text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Déclaration des contrôleurs pour les champs d'entrée
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isObsecureText = true; // Variable pour cacher/afficher le mot de passe

  @override
  void dispose() {
    // Libérer la mémoire quand la page se ferme
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Fermer le clavier en cliquant hors du champ
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(50.w, 20.h, 50.w, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Titre de la page
                  Center(
                    child: ReusableTextWidget(
                      text: "sign_in".tr, // Texte traduit (connexion)
                      textSize: 100,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),

                  SizedBox(height: 40.h),
                  // Image de connexion
                  Image.asset(
                    'assets/images/Login.png',
                    height: 1000.h,
                    width: 900.w,
                  ),
                  SizedBox(height: 100.h),

                  // Champ de texte pour l'email
                  ReusableTextFieldWidget(
                    fillColor: const Color(0xfffafcfc),
                    borderSide: const BorderSide(
                      color: Color(0xfff3f6f9),
                      width: 3,
                      style: BorderStyle.solid,
                    ),
                    hintText: "email".tr, // Texte traduit (email)
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  SizedBox(height: 20.h),

                  // Champ de texte pour le mot de passe
                  ReusableTextFieldWidget(
                    fillColor: const Color(0xfffafcfc),
                    borderSide: const BorderSide(
                      color: Color(0xfff3f6f9),
                      width: 3,
                      style: BorderStyle.solid,
                    ),
                    onPressedSuffixIcon: () {
                      setState(() {
                        _isObsecureText = !_isObsecureText; // Afficher/Cacher le mot de passe
                      });
                    },
                    obsecureText: _isObsecureText,
                    hintText: "password".tr, // Texte traduit (mot de passe)
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                  ),

                  SizedBox(height: 20.h),

                  // Texte "Mot de passe oublié"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReusableTextWidget(
                        text: "forgot_password".tr,
                        textSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),

                  SizedBox(height: 70.h),

                  // Bouton de connexion
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
                        Get.toNamed('/home'); // Naviguer vers la page d'accueil après connexion
                      },
                      child: ReusableTextWidget(
                        text: "connect_button_text",
                        textSize: 55,
                        fontWeight: FontWeight.w900,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),

                  SizedBox(height: 60.h),

                  // Texte "Pas encore de compte ?"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ReusableTextWidget(
                        text: "no_account".tr,
                        textSize: 45,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 15.w),
                      GestureDetector(
                        onTap: () {
                          navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                            context,
                            SignupScreen(), // Aller vers l'inscription
                          );
                        },
                        child: Text(
                          "sign_up".tr,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 45.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 80.h),

                  // Ou se connecter avec Google
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Or".tr,
                          style: GoogleFonts.raleway(
                            color: Colors.grey,
                            fontSize: 45.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                    ],
                  ),

                  SizedBox(height: 60.h),

                  // Bouton de connexion avec Google
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
                        Get.updateLocale(Locale('fr', 'FR')); // Changer la langue en français
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.google,
                            color: AppColors.whiteColor,
                          ),
                          SizedBox(width: 40.w),
                          Text(
                            "continue_with_google".tr,
                            style: GoogleFonts.raleway(
                              fontSize: 55.sp,
                              fontWeight: FontWeight.w900,
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
          ),
        ),
      ),
    );
  }
}
