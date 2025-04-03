import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lottie/lottie.dart';
import 'package:medical_app/features/authentication/presentation/pages/reset_password_screen.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../widgets/reusable_text_widget.dart';


class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({Key? key}) : super(key: key);

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
          child: Column(
            children: [
              // Section supérieure avec une décoration
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
                      Lottie.asset("assets/lotties/code.json", height: 350.h),
                      SizedBox(height: 20.h),
                      ReusableTextWidget(
                        text: "Vérification du code",
                        textSize: 60,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),

              // Champ pour le code de vérification
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableTextWidget(
                      text: "Code de vérification :",
                      textSize: 50,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 20.h),
                    OtpTextField(
                      numberOfFields: 4,
                      borderColor: AppColors.primaryColor,
                      focusedBorderColor: AppColors.primaryColor,
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {
                        // Logique lorsque le code est modifié
                      },
                      onSubmit: (String verificationCode) {
                        // Logique lorsque le code est soumis
                        Get.to(() => ResetPasswordScreen());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}