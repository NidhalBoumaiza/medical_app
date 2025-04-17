import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medical_app/cubit/toggle%20cubit/toggle_cubit.dart';

import 'package:medical_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/authentication/presentation/blocs/Signup BLoC/signup_bloc.dart';
import 'features/authentication/presentation/blocs/login BLoC/login_bloc.dart';
import 'i18n/app_translation.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await di.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();


  runApp(MyApp(initialScreen: LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<LoginBloc>()),
        BlocProvider(create: (context) => di.sl<SignupBloc>()),
        BlocProvider(create: (context) => di.sl<ToggleCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1344, 2992),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Medical App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: initialScreen,
            translations: AppTranslations(),
            locale: Get.deviceLocale,
            fallbackLocale: const Locale('fr', 'FR'),
          );
        },
      ),
    );
  }
}

