import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/reusable_text_field_widget.dart';
import '../../../../widgets/reusable_text_widget.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context), // Get.back(), (Pour retourner à la page précédente)
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
                          text: "Restaurer votre mot de passe",
                          textSize: 60,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // Champ pour l'e-mail
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableTextWidget(
                        text: "Email :",
                        textSize: 50,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 10.h),
                      ReusableTextFieldWidget(
                        controller: emailController,
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        prefixIconColor: AppColors.primaryColor,
                        fillColor: Colors.white,
                        validatorFunction: (value) {
                          if (value == null || value.isEmpty) {
                            return "L'email est obligatoire";
                          }
                          if (!value.contains("@")) {
                            return "Veuillez saisir un email validé";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // Bouton "Envoyer"
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: loading
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
                          setState(() {
                            loading = true;
                          });
                          // Simuler une requête API
                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              loading = false;
                            });
                            Get.to(() => VerifyCodeScreen());
                          });
                        }
                      },
                      child: ReusableTextWidget(
                        text: "Envoyer",
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