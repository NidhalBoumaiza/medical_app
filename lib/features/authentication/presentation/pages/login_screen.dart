import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/authentication/presentation/pages/forgot_password_screen.dart';
import 'package:medical_app/features/authentication/presentation/pages/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../../../widgets/reusable_text_widget.dart';
import '../../../home/presentation/pages/home_medecin.dart';
import '../../../home/presentation/pages/home_patient.dart';
import '../blocs/login BLoC/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObsecureText = true;

  @override
  void dispose() {
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
                      text: "sign_in".tr,
                      textSize: 100,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Image.asset(
                    'assets/images/Login.png',
                    height: 1000.h,
                    width: 900.w,
                  ),
                  SizedBox(height: 100.h),
                  // Wrap input fields in a Form widget
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Champ de texte pour l'email
                        ReusableTextFieldWidget(
                          fillColor: const Color(0xfffafcfc),
                          borderSide: const BorderSide(
                            color: Color(0xfff3f6f9),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                          hintText: "email".tr,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validatorFunction: (value) {
                            if (value == null || value.isEmpty) {
                              return "L'email est obligatoire".tr;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return "Veuillez entrer un email valide".tr;
                            }
                            return null;
                          },
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
                              _isObsecureText = !_isObsecureText;
                            });
                          },
                          obsecureText: _isObsecureText,
                          hintText: "password".tr,
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          validatorFunction: (value) {
                            if (value == null || value.isEmpty) {
                              return "Le mot de passe est obligatoire".tr;
                            }
                            if (value.length < 6) {
                              return "Le mot de passe doit contenir au moins 6 caractères"
                                  .tr;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Texte "Mot de passe oublié"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: ReusableTextWidget(
                          text: "forgot_password".tr,
                          textSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 70.h),
                  // Bouton de connexion avec Bloc
                  BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) async {
                      if (state is LoginSuccess) {
                        showSuccessSnackBar(context, "login_success".tr);
                        if (state.user.role == "medecin"){
                          navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                            context,
                            const HomeMedecin(),
                          );
                        }else {
                          navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                            context,
                            const HomePatient(),
                          );
                        }
                      } else if (state is LoginError) {
                        showErrorSnackBar(context, "invalid_credentials".tr);

                      }
                    },
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
                          onPressed: state is LoginLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<LoginBloc>().add(
                                LoginWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              );
                            }
                          },
                          child: state is LoginLoading
                              ? CircularProgressIndicator(
                              color: AppColors.whiteColor)
                              : ReusableTextWidget(
                            text: "connect_button_text".tr,
                            textSize: 55,
                            fontWeight: FontWeight.w900,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      );
                    },
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
                            SignupScreen(),
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
                  // Bouton de connexion avec Google avec Bloc
                  BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) async {
                      if (state is LoginSuccess) {
                        showSuccessSnackBar(context, "login_success".tr);
                       if (state.user.role == "medecin"){
                         navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                           context,
                           const HomeMedecin(),
                         );
                       }else {
                         navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                           context,
                           const HomePatient(),
                         );
                       }

                      } else if (state is LoginError) {
                        showErrorSnackBar(context, "invalid_credentials".tr);
                      }
                    },
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
                          onPressed: state is LoginLoading
                              ? null
                              : () {
                            context.read<LoginBloc>().add(LoginWithGoogle());
                          },
                          child: state is LoginLoading
                              ? CircularProgressIndicator(
                              color: AppColors.whiteColor)
                              : Row(
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
                      );
                    },
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