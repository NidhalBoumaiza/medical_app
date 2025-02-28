import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/widgets/reusable_text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(50.w, 20.h, 50.w, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "sign_in".tr, // Translated title
                      style: GoogleFonts.raleway(
                        fontSize: 100.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Image.asset(
                    'assets/images/Login.png',
                    height: 1000.h,
                    width: 900.w,
                  ),
                  SizedBox(height: 100.h),
                  ReusableTextFieldWidget(
                    borderSide: BorderSide(color: Colors.blueGrey),
                    hintText: "email".tr, // Translated hint
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20.h),
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
                    // Translated hint
                    controller: passwordController,
                    keyboardType: TextInputType.text, // Changed for password
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "forgot_password".tr, // Translated text
                        style: GoogleFonts.raleway(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 70.h),
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
                        // Add login logic here, then navigate
                        Get.toNamed('/home'); // Changed from /sign_in to /home
                      },
                      child: Text(
                        "connect_button_text".tr, // Translated button text
                        style: GoogleFonts.raleway(
                          fontSize: 55.sp,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w900,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "no_account".tr, // Translated text
                        style: GoogleFonts.raleway(
                          fontSize: 45.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('/sign_up'); // Navigate to sign-up
                        },
                        child: Text(
                          "sign_up".tr, // Translated text
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
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Or".tr, // Translated text
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
                        Get.updateLocale(Locale('fr', 'FR'));
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
                            "continue_with_google".tr, // Translated text
                            style: GoogleFonts.raleway(
                              fontSize: 55.sp,
                              letterSpacing: 1,
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
