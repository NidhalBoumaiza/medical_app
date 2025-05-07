import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medical_app/core/utils/app_themes.dart';
import 'package:medical_app/core/utils/theme_manager.dart';
import 'package:medical_app/cubit/theme_cubit/theme_cubit.dart';
import 'package:medical_app/cubit/toggle%20cubit/toggle_cubit.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';
import 'package:medical_app/features/authentication/presentation/blocs/Signup%20BLoC/signup_bloc.dart';
import 'package:medical_app/features/authentication/presentation/blocs/login%20BLoC/login_bloc.dart';
import 'package:medical_app/features/authentication/presentation/pages/login_screen.dart';
import 'package:medical_app/features/home/presentation/pages/home_medecin.dart';
import 'package:medical_app/features/home/presentation/pages/home_patient.dart';
import 'package:medical_app/features/ratings/presentation/bloc/rating_bloc.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';
import 'package:medical_app/injection_container.dart' as di;
import 'package:provider/provider.dart';
import 'features/authentication/presentation/blocs/forget password bloc/forgot_password_bloc.dart';
import 'features/authentication/presentation/blocs/reset password bloc/reset_password_bloc.dart';
import 'features/authentication/presentation/blocs/verify code bloc/verify_code_bloc.dart';
import 'features/messagerie/presentation/blocs/conversation%20BLoC/conversations_bloc.dart';
import 'features/messagerie/presentation/blocs/messageries%20BLoC/messagerie_bloc.dart';
import 'features/profile/presentation/pages/blocs/BLoC update profile/update_user_bloc.dart';
import 'i18n/app_translation.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  
  // Initialize French locale for date formatting (used in appointment details)
  await initializeDateFormatting('fr_FR', null);
  
  // Initialize dependency injection
  await di.init();

  final authLocalDataSource = di.sl<AuthLocalDataSource>();
  Widget initialScreen;

  // Get saved language
  final savedLocale = await LanguageService.getSavedLanguage();

  try {
    final token = await authLocalDataSource.getToken();
    print('Token: $token');
    final user = await authLocalDataSource.getUser();
    if (token != null && user.id!.isNotEmpty) {
      initialScreen = user.role == 'medecin' ? const HomeMedecin() : const HomePatient();
    } else {
      initialScreen = const LoginScreen();
    }
  } catch (e) {
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen, savedLocale: savedLocale));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  final Locale? savedLocale;

  const MyApp({Key? key, required this.initialScreen, this.savedLocale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<ToggleCubit>()),
        BlocProvider(create: (_) => di.sl<LoginBloc>()),
        BlocProvider(create: (_) => di.sl<SignupBloc>()),
        BlocProvider(create: (_) => di.sl<UpdateUserBloc>()),
        BlocProvider(create: (_) => di.sl<ForgotPasswordBloc>()),
        BlocProvider(create: (_) => di.sl<VerifyCodeBloc>()),
        BlocProvider(create: (_) => di.sl<ResetPasswordBloc>()),
        BlocProvider(create: (_) => di.sl<RendezVousBloc>()),
        BlocProvider(create: (_) => di.sl<ConversationsBloc>()),
        BlocProvider(create: (_) => di.sl<MessagerieBloc>()),
        BlocProvider(create: (_) => di.sl<RatingBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final themeMode = themeState is ThemeLoaded 
              ? themeState.themeMode 
              : ThemeMode.light;
          
          return ScreenUtilInit(
            designSize: const Size(360, 800),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Medical App',
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: themeMode,
                home: initialScreen,
                translations: AppTranslations(),
                locale: savedLocale ?? Get.deviceLocale,
                fallbackLocale: const Locale('fr', 'FR'),
              );
            },
          );
        },
      ),
    );
  }
}