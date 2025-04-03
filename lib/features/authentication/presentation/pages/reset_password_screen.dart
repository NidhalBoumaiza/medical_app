import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:medical_app/cubit/Confirm%20Password/confirm_password_cubit.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../../../cubit/Confirm Password/confirm_password_cubit.dart';
import '../../../../widgets/reusable_text_widget.dart';
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 600.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(300.r),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset("assets/lotties/reset.json", height: 350.h),

                        SizedBox(height: 20.h),
                        ReusableTextWidget(
                          text: "Réinitialiser le mot de passe",
                          textSize: 60,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // Champ pour le nouveau mot de passe
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: "Nouveau mot de passe :",
                        textSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 10.h),
                      //BlocBuilder
                      BlocBuilder <ConfirmPasswordCubit,ConfirmPasswordState>(
                          builder: (context,state){

                            return ReusableTextFieldWidget(
                              controller: newPasswordController,
                              hintText: "Nouveau mot de passe",

                              obsecureText: state is ConfirmPasswordInVisible,

                              onPressedSuffixIcon: () {

                                context.read<ConfirmPasswordCubit>().TogglePasswordVisibility();
                              },
                              validatorFunction: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Le mot de passe est obligatoire";
                                }
                                if (value.length < 8 ) {
                                  return "Le mot de passe doit contenir au moins 8 caractères";
                                }
                                return null;
                              },
                            );
                          }
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Champ pour confirmer le mot de passe
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: "Confirmer le mot de passe :",
                        textSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 10.h),
                      ReusableTextFieldWidget(
                        controller: confirmPasswordController,
                        hintText: "Confirmer le mot de passe",
                        obsecureText: _isObscureConfirmPassword,
                        onPressedSuffixIcon: () {
                          setState(() {
                            _isObscureConfirmPassword = !_isObscureConfirmPassword;
                          });
                        },
                        validatorFunction: (value) {
                          if (value == null || value.isEmpty) {
                            return "La confirmation est obligatoire";
                          }
                          if (value != newPasswordController.text) {
                            return "Les mots de passe ne correspondent pas";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // Bouton "Réinitialiser"
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Get.snackbar(
                            "Succès",
                            "Votre mot de passe a été réinitialisé avec succès.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: ReusableTextWidget(
                        text: "Réinitialiser",
                        textSize: 60,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}