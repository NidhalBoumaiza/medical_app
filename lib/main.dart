import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:medical_app/screens/login_screen.dart';
import 'package:medical_app/screens/signup_screen.dart';

import 'cubit/toggle cubit/toggle_cubit.dart';
import 'i18n/app_translation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(

      designSize: const Size(1344, 2992),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {

        //enregistrement du cubit dans la page main "racine"
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ToggleCubit(),
            ),
          ],


          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            translations: AppTranslation(),
            locale: const Locale('fr', 'FR'),
            fallbackLocale: const Locale('fr', 'FR'),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: SignupScreen(),
          ),
        );
      },
    );
  }
}
