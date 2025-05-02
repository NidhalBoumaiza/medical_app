import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/core/widgets/reusable_text_field_widget.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_remote_data_source.dart';
import 'package:medical_app/widgets/reusable_text_widget.dart';
import 'package:lottie/lottie.dart';

import '../blocs/forget%20password%20bloc/forgot_password_bloc.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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
                        Lottie.asset("assets/lotties/forgotpassword.json", height: 350.h),
                        SizedBox(height: 20.h),
                        ReusableTextWidget(
                          text: "Restaurer votre mot de passe".tr,
                          textSize: 60,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: "Email :".tr,
                        textSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 10.h),
                      ReusableTextFieldWidget(
                        controller: emailController,
                        hintText: "Email".tr,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        prefixIconColor: AppColors.primaryColor,
                        fillColor: Colors.white,
                        validatorFunction: (value) {
                          if (value == null || value.isEmpty) {
                            return "L'email est obligatoire".tr;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return "Veuillez saisir un email validé".tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
                  listener: (context, state) {
                    if (state is ForgotPasswordSuccess) {
                      showSuccessSnackBar(context, "Code de vérification envoyé".tr);
                      navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                        context,
                        VerifyCodeScreen(
                          email: emailController.text,
                          isAccountCreation: false,
                        ),
                      );
                    } else if (state is ForgotPasswordError) {
                      String errorMessage = state.message.tr;
                      if (state.message == 'User not found') {
                        errorMessage = "Utilisateur non trouvé".tr;
                      }
                      showErrorSnackBar(context, errorMessage);
                    }
                  },
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50.w),
                      child: state is ForgotPasswordLoading
                          ? CircularProgressIndicator(color: AppColors.primaryColor)
                          : SizedBox(
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
                              context.read<ForgotPasswordBloc>().add(
                                SendVerificationCode(
                                  email: emailController.text,
                                  codeType: VerificationCodeType.motDePasseOublie,
                                ),
                              );
                            }
                          },
                          child: ReusableTextWidget(
                            text: "Envoyer".tr,
                            textSize: 60,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
    );
  }
}