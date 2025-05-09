import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/core/widgets/reusable_text_field_widget.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_remote_data_source.dart';
import 'package:medical_app/features/authentication/presentation/blocs/Signup%20BLoC/signup_bloc.dart';
import 'package:medical_app/features/authentication/presentation/pages/verify_code_screen.dart';

import '../blocs/forget password bloc/forgot_password_bloc.dart';

class PasswordScreen extends StatefulWidget {
  final dynamic entity; // Can be PatientEntity or MedecinEntity

  const PasswordScreen({super.key, required this.entity});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
              'Mot de passe',
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
                      "Mot de passe :",
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ReusableTextFieldWidget(
                      obsecureText: _isObscurePassword,
                      controller: passwordController,
                      fillColor: const Color(0xfffafcfc),
                      borderSide: const BorderSide(
                        color: Color(0xfff3f6f9),
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                      hintText: "Mot de passe".tr,
                      keyboardType: TextInputType.text,
                      errorMessage: "Mot de passe est obligatoire".tr,
                      validatorFunction: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mot de passe est obligatoire".tr;
                        }
                        if (value.length < 8) {
                          return "Le mot de passe doit contenir au moins 8 caractères".tr;
                        }
                        return null;
                      },
                      onPressedSuffixIcon: () {
                        setState(() {
                          _isObscurePassword = !_isObscurePassword;
                        });
                      },
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      "Confirmer le mot de passe :",
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ReusableTextFieldWidget(
                      obsecureText: _isObscureConfirmPassword,
                      controller: confirmPasswordController,
                      fillColor: const Color(0xfffafcfc),
                      borderSide: const BorderSide(
                        color: Color(0xfff3f6f9),
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                      hintText: "Confirmer le mot de passe".tr,
                      keyboardType: TextInputType.text,
                      errorMessage: "Confirmation du mot de passe est obligatoire".tr,
                      validatorFunction: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirmation du mot de passe est obligatoire".tr;
                        }
                        if (value != passwordController.text) {
                          return "Les mots de passe ne correspondent pas".tr;
                        }
                        return null;
                      },
                      onPressedSuffixIcon: () {
                        setState(() {
                          _isObscureConfirmPassword = !_isObscureConfirmPassword;
                        });
                      },
                    ),
                    SizedBox(height: 100.h),
                    BlocConsumer<SignupBloc, SignupState>(
                      listener: (context, state) {
                        if (state is SignupSuccess) {
                          showSuccessSnackBar(context, "Inscription réussie".tr);
                          context.read<ForgotPasswordBloc>().add(
                            SendVerificationCode(
                              email: widget.entity.email,
                              codeType: VerificationCodeType.activationDeCompte,
                            ),
                          );
                        } else if (state is SignupError) {
                          showErrorSnackBar(context, state.message.tr);
                        }
                      },
                      builder: (context, state) {
                        return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
                          listener: (context, forgotState) {
                            if (forgotState is ForgotPasswordSuccess) {
                              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                context,
                                VerifyCodeScreen(
                                  email: widget.entity.email,
                                  isAccountCreation: true,
                                ),
                              );
                            } else if (forgotState is ForgotPasswordError) {
                              showErrorSnackBar(context, forgotState.message.tr);
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 200.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              onPressed: state is SignupLoading
                                  ? null
                                  : () {
                                if (_formKey.currentState!.validate()) {
                                  if (passwordController.text != confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Les mots de passe ne correspondent pas".tr),
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<SignupBloc>().add(
                                    SignupWithUserEntity(
                                      user: widget.entity,
                                      password: passwordController.text,
                                    ),
                                  );
                                }
                              },
                              child: state is SignupLoading
                                  ? CircularProgressIndicator(color: AppColors.whiteColor)
                                  : Text(
                                "S'inscrire".tr,
                                style: GoogleFonts.raleway(
                                  fontSize: 60.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.whiteColor,
                                ),
                              ),
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
      ),
    );
  }
}