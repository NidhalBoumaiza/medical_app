import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medical_app/cubit/toggle%20cubit/toggle_cubit.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';
import 'package:medical_app/features/authentication/presentation/blocs/Signup%20BLoC/signup_bloc.dart';
import 'package:medical_app/features/authentication/presentation/blocs/login%20BLoC/login_bloc.dart';
import 'package:medical_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:medical_app/features/home/presentation/pages/home_medecin.dart';
import 'package:medical_app/features/home/presentation/pages/home_patient.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';
import 'package:medical_app/injection_container.dart' as di;

import 'i18n/app_translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await di.init();

  // Get AuthLocalDataSource to check authentication status
  final authLocalDataSource = di.sl<AuthLocalDataSource>();
  Widget initialScreen;

  try {
    final token = await authLocalDataSource.getToken();
    final user = await authLocalDataSource.getUser();
    if (token != null && user.id!.isNotEmpty) {
      // User is authenticated; redirect based on role
      initialScreen = user.role == 'medecin' ? const HomeMedecin() : const HomePatient();
    } else {
      // No valid token or user; redirect to LoginScreen
      initialScreen = const LoginScreen();
    }
  } catch (e) {
    // Error retrieving user or token; redirect to LoginScreen
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
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
        BlocProvider(create: (context) => di.sl<RendezVousBloc>()),
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