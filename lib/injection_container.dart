import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/cubit/toggle%20cubit/toggle_cubit.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_local_data_source.dart';
import 'package:medical_app/features/authentication/data/data%20sources/auth_remote_data_source.dart';
import 'package:medical_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:medical_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:medical_app/features/authentication/domain/usecases/create_account_use_case.dart';
import 'package:medical_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:medical_app/features/authentication/presentation/blocs/Signup%20BLoC/signup_bloc.dart';
import 'package:medical_app/features/authentication/presentation/blocs/login%20BLoC/login_bloc.dart';
import 'package:medical_app/features/messagerie/data/data_sources/message_local_datasource.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_messages_stream_usecase.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/messageries%20BLoC/messagerie_bloc.dart';
import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_local_data_source.dart';
import 'package:medical_app/features/rendez_vous/data/data%20sources/rdv_remote_data_source.dart';
import 'package:medical_app/features/rendez_vous/data/repositories/rendez_vous_repository_impl.dart';
import 'package:medical_app/features/rendez_vous/domain/repositories/rendez_vous_repository.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/assign_doctor_to_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/create_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_doctors_by_specialty_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/fetch_rendez_vous_use_case.dart';
import 'package:medical_app/features/rendez_vous/domain/usecases/update_rendez_vous_status_use_case.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/messagerie/data/data_sources/message_remote_datasource.dart';
import 'features/messagerie/data/repositories/message_repository_impl.dart';
import 'features/messagerie/domain/repositories/message_repository.dart';
import 'features/messagerie/domain/use_cases/get_conversations.dart';
import 'features/messagerie/domain/use_cases/get_message.dart';
import 'features/messagerie/domain/use_cases/send_message.dart';
import 'features/messagerie/presentation/blocs/conversation BLoC/conversations_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs and Cubits
  sl.registerFactory(() => LoginBloc(loginUseCase: sl()));
  sl.registerFactory(() => SignupBloc(createAccountUseCase: sl()));
  sl.registerFactory(() => ToggleCubit());
  sl.registerFactory(() => RendezVousBloc(
    fetchRendezVousUseCase: sl(),
    updateRendezVousStatusUseCase: sl(),
    createRendezVousUseCase: sl(),
    fetchDoctorsBySpecialtyUseCase: sl(),
    assignDoctorToRendezVousUseCase: sl(),
  ));
  sl.registerFactory(() => ConversationsBloc(getConversationsUseCase: sl(),));
  sl.registerFactory(()=>MessagerieBloc(sendMessageUseCase: sl(), getMessagesUseCase:  sl(), getMessagesStreamUseCase: sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CreateAccountUseCase(sl()));
  sl.registerLazySingleton(() => FetchRendezVousUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRendezVousStatusUseCase(sl()));
  sl.registerLazySingleton(() => CreateRendezVousUseCase(sl()));
  sl.registerLazySingleton(() => FetchDoctorsBySpecialtyUseCase(sl()));
  sl.registerLazySingleton(() => AssignDoctorToRendezVousUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesStreamUseCase(sl()));
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<RendezVousRepository>(
        () => RendezVousRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<MessagingRepository>(
        () => MessagingRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data Sourcess

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<RendezVousRemoteDataSource>(
        () => RendezVousRemoteDataSourceImpl(
      firestore: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<RendezVousLocalDataSource>(
        () => RendezVousLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<MessagingRemoteDataSource>(
        () => MessagingRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<MessagingLocalDataSource>(
        () => MessagingLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton<InternetConnectionChecker>(
        () => InternetConnectionChecker.instance,
  );
}