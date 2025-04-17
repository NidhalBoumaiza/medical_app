import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical_app/core/error/exceptions.dart';

import '../models/medecin_model.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';
import 'auth_local_data_source.dart';

abstract class AuthRemoteDataSource {
  Future<void> signInWithGoogle();
  Future<Unit> createAccount(UserModel user, String password);
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;
  final AuthLocalDataSource localDataSource;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
    required this.localDataSource,
  });

  @override
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google Sign-In cancelled');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final userData = UserModel(
          id: user.uid,
          name: user.displayName?.split(' ').first ?? '',
          lastName: user.displayName?.split(' ').last ?? '',
          email: user.email ?? '',
          role: 'patient',
          gender: 'Homme',
          phoneNumber: user.phoneNumber ?? '',
          dateOfBirth: null,
        );
        await firestore.collection('users').doc(user.uid).set(userData.toJson());
        await localDataSource.cacheUser(userData);
        await localDataSource.saveToken(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google Sign-In failed');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Unit> createAccount(UserModel user, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final collection = user is PatientModel
            ? 'patients'
            : user is MedecinModel
            ? 'medecins'
            : 'users';
        UserModel updatedUser;
        if (user is PatientModel) {
          updatedUser = PatientModel(
            id: firebaseUser.uid,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            antecedent: user.antecedent,
          );
        } else if (user is MedecinModel) {
          updatedUser = MedecinModel(
            id: firebaseUser.uid,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            speciality: user.speciality,
            numLicence: user.numLicence,
          );
        } else {
          updatedUser = UserModel(
            id: firebaseUser.uid,
            name: user.name,
            lastName: user.lastName,
            email: user.email,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
          );
        }
        await firestore.collection(collection).doc(firebaseUser.uid).set(updatedUser.toJson());
        await localDataSource.cacheUser(updatedUser);
        await localDataSource.saveToken(firebaseUser.uid);
        return unit;
      } else {
        throw AuthException('User creation failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw ServerMessageException('Email already in use');
      } else if (e.code == 'weak-password') {
        throw AuthException('Password is too weak');
      } else {
        throw AuthException(e.message ?? 'Account creation failed');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Try fetching from patients collection
        final patientDoc = await firestore.collection('patients').doc(firebaseUser.uid).get();
        if (patientDoc.exists) {
          final user = PatientModel.fromJson(patientDoc.data()!);
          await localDataSource.cacheUser(user);
          await localDataSource.saveToken(firebaseUser.uid);
          return user;
        }
        // Try fetching from medecins collection
        final medecinDoc = await firestore.collection('medecins').doc(firebaseUser.uid).get();
        if (medecinDoc.exists) {
          final user = MedecinModel.fromJson(medecinDoc.data()!);
          await localDataSource.cacheUser(user);
          await localDataSource.saveToken(firebaseUser.uid);
          return user;
        }
        // Fallback to users collection
        final userDoc = await firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          final user = UserModel.fromJson(userDoc.data()!);
          await localDataSource.cacheUser(user);
          await localDataSource.saveToken(firebaseUser.uid);
          return user;
        }
        throw AuthException('User data not found');
      } else {
        throw AuthException('Login failed');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw UnauthorizedException('Invalid email or password');
      } else {
        throw AuthException(e.message ?? 'Login failed');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}