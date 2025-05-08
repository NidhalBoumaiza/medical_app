import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/authentication/data/models/medecin_model.dart';
import 'package:medical_app/features/authentication/data/models/patient_model.dart';
import 'package:medical_app/features/authentication/data/models/user_model.dart';
import 'auth_local_data_source.dart';

enum VerificationCodeType {
  compteActive,
  activationDeCompte,
  motDePasseOublie,
  changerMotDePasse,
}

abstract class AuthRemoteDataSource {
  Future<void> signInWithGoogle();
  Future<Unit> createAccount(UserModel user, String password);
  Future<UserModel> login(String email, String password);
  Future<Unit> updateUser(UserModel user);
  Future<Unit> sendVerificationCode({
    required String email,
    required VerificationCodeType codeType,
  });
  Future<Unit> verifyCode({
    required String email,
    required int verificationCode,
    required VerificationCodeType codeType,
  });
  Future<Unit> changePassword({
    required String email,
    required String newPassword,
    required int verificationCode,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;
  final AuthLocalDataSource localDataSource;
  final String emailServiceUrl = 'http://192.168.1.11:3000/api/v1/users'; //adresse ip de notre pc

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
    required this.localDataSource,
  });

  int generateFourDigitNumber() {
    final random = Random();
    return 1000 + random.nextInt(9000);
  }

  String getSubjectForCodeType(VerificationCodeType codeType) {
    switch (codeType) {
      case VerificationCodeType.compteActive:
        return 'Compte Activé';
      case VerificationCodeType.activationDeCompte:
        return 'Activation de compte';
      case VerificationCodeType.motDePasseOublie:
        return 'Mot de passe oublié';
      case VerificationCodeType.changerMotDePasse:
        return 'Changer mot de passe';
    }
  }

  Future<void> sendVerificationEmail({
    required String email,
    required String subject,
    required int code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$emailServiceUrl/sendMailService'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'subject': subject,
          'code': code,
        }),
      );
      if (response.statusCode != 201) {
        throw ServerException('Failed to send verification email: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Unexpected error sending email: $e');
    }
  }

  Future<void> clearVerificationCode({
    required String collection,
    required String docId,
  }) async {
    await firestore.collection(collection).doc(docId).update({
      'verificationCode': null,
      'validationCodeExpiresAt': null,
    });
  }

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
          email: user.email?.toLowerCase().trim() ?? '',
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
      print('createAccount: Starting for email=${user.email}');
      final normalizedEmail = user.email.toLowerCase().trim();
      final collections = ['patients', 'medecins', 'users'];
      for (var collection in collections) {
        print('createAccount: Checking collection=$collection for email=$normalizedEmail');
        final emailQuery = await firestore
            .collection(collection)
            .where('email', isEqualTo: normalizedEmail)
            .get();
        print('createAccount: Email query result: ${emailQuery.docs.length} docs found');
        if (emailQuery.docs.isNotEmpty) {
          throw UsedEmailOrPhoneNumberException('Email already used');
        }
        if (user.phoneNumber.isNotEmpty) {
          print('createAccount: Checking phoneNumber=${user.phoneNumber}');
          final phoneQuery = await firestore
              .collection(collection)
              .where('phoneNumber', isEqualTo: user.phoneNumber)
              .get();
          print('createAccount: Phone query result: ${phoneQuery.docs.length} docs found');
          if (phoneQuery.docs.isNotEmpty) {
            throw UsedEmailOrPhoneNumberException('Phone number already used');
          }
        }
      }

      print('createAccount: Creating Firebase Auth user with email=$normalizedEmail');
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        print('createAccount: Firebase user created, UID=${firebaseUser.uid}');
        final randomNumber = generateFourDigitNumber();
        print('createAccount: Generated verificationCode=$randomNumber');
        final collection = user is PatientModel
            ? 'patients'
            : user is MedecinModel
            ? 'medecins'
            : 'users';
        print('createAccount: Using collection=$collection');
        UserModel updatedUser;
        if (user is PatientModel) {
          updatedUser = PatientModel(
            id: firebaseUser.uid,
            name: user.name,
            lastName: user.lastName,
            email: normalizedEmail,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            antecedent: user.antecedent,
            accountStatus: false,
            verificationCode: randomNumber,
            validationCodeExpiresAt: DateTime.now().add(const Duration(minutes: 60)),
          );
        } else if (user is MedecinModel) {
          updatedUser = MedecinModel(
            id: firebaseUser.uid,
            name: user.name,
            lastName: user.lastName,
            email: normalizedEmail,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            speciality: user.speciality,
            numLicence: user.numLicence,
            accountStatus: false,
            verificationCode: randomNumber,
            validationCodeExpiresAt: DateTime.now().add(const Duration(minutes: 60)),
          );
        } else {
          updatedUser = UserModel(
            id: firebaseUser.uid,
            name: user.name,
            lastName: user.lastName,
            email: normalizedEmail,
            role: user.role,
            gender: user.gender,
            phoneNumber: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            verificationCode: randomNumber,
            validationCodeExpiresAt: DateTime.now().add(const Duration(minutes: 60)),
          );
        }
        print('createAccount: Saving user to Firestore');
        await firestore.collection(collection).doc(firebaseUser.uid).set(updatedUser.toJson());
        print('createAccount: Caching user locally');
        await localDataSource.cacheUser(updatedUser);
        print('createAccount: Saving token');
        await localDataSource.saveToken(firebaseUser.uid);
        print('createAccount: Sending verification code');
        await sendVerificationCode(
          email: normalizedEmail,
          codeType: VerificationCodeType.activationDeCompte,
        );
        print('createAccount: Completed successfully');
        return unit;
      } else {
        print('createAccount: Error - Firebase user creation failed');
        throw AuthException('User creation failed');
      }
    } on FirebaseAuthException catch (e) {
      print('createAccount: FirebaseAuthException: code=${e.code}, message=${e.message}');
      if (e.code == 'email-already-in-use') {
        throw UsedEmailOrPhoneNumberException('Email already in use');
      } else if (e.code == 'weak-password') {
        throw AuthException('Password is too weak');
      } else {
        throw AuthException(e.message ?? 'Account creation failed');
      }
    } catch (e) {
      print('createAccount: Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      print('login: Starting for email=$email');
      final normalizedEmail = email.toLowerCase().trim();
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        print('login: Firebase user signed in, UID=${firebaseUser.uid}');
        final patientDoc = await firestore.collection('patients').doc(firebaseUser.uid).get();
        if (patientDoc.exists) {
          final user = PatientModel.fromJson(patientDoc.data()!);
          print('login: Found user in patients, email=${user.email}');
          await localDataSource.cacheUser(user);
          await localDataSource.saveToken(firebaseUser.uid);
          return user;
        }
        final medecinDoc = await firestore.collection('medecins').doc(firebaseUser.uid).get();
        if (medecinDoc.exists) {
          final user = MedecinModel.fromJson(medecinDoc.data()!);
          print('login: Found user in medecins, email=${user.email}');
          await localDataSource.cacheUser(user);
          await localDataSource.saveToken(firebaseUser.uid);
          return user;
        }
        final userDoc = await firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          final user = UserModel.fromJson(userDoc.data()!);
          print('login: Found user in users, email=${user.email}');
          await localDataSource.cacheUser(user);
          await localDataSource.saveToken(firebaseUser.uid);
          return user;
        }
        print('login: Error - User data not found in Firestore');
        throw AuthException('User data not found');
      } else {
        print('login: Error - Firebase sign-in failed');
        throw AuthException('Login failed');
      }
    } on FirebaseAuthException catch (e) {
      print('login: FirebaseAuthException: code=${e.code}, message=${e.message}');
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw UnauthorizedException('Invalid email or password');
      } else {
        throw AuthException(e.message ?? 'Login failed');
      }
    } catch (e) {
      print('login: Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Unit> updateUser(UserModel user) async {
    try {
      print('updateUser: Starting for user id=${user.id}, email=${user.email}');
      final normalizedEmail = user.email.toLowerCase().trim();
      final collection = user is PatientModel
          ? 'patients'
          : user is MedecinModel
          ? 'medecins'
          : 'users';
      
      // Check if appointmentDuration has changed (for doctors)
      if (user is MedecinModel) {
        try {
          final existingDoctor = await firestore.collection('medecins').doc(user.id).get();
          if (existingDoctor.exists) {
            final existingData = existingDoctor.data();
            final existingDuration = existingData?['appointmentDuration'] as int? ?? 30;
            
            // If duration has changed, we'll need to update appointments
            if (existingDuration != user.appointmentDuration) {
              print('updateUser: Detected change in appointmentDuration from $existingDuration to ${user.appointmentDuration}');
              
              // First update the doctor record
              final updatedUser = MedecinModel(
                id: user.id,
                name: user.name,
                lastName: user.lastName,
                email: normalizedEmail,
                role: user.role,
                gender: user.gender,
                phoneNumber: user.phoneNumber,
                dateOfBirth: user.dateOfBirth,
                speciality: user.speciality,
                numLicence: user.numLicence,
                appointmentDuration: user.appointmentDuration,
                accountStatus: user.accountStatus,
                verificationCode: user.verificationCode,
                validationCodeExpiresAt: user.validationCodeExpiresAt,
              );
              
              print('updateUser: Updating doctor record with new duration');
              await firestore.collection(collection).doc(user.id).set(updatedUser.toJson());
              
              // Then update future appointments
              print('updateUser: Updating future appointments');
              await _updateFutureAppointmentsEndTime(user.id!, user.appointmentDuration);
              
              // Cache updated user
              print('updateUser: Caching updated user locally');
              await localDataSource.cacheUser(updatedUser);
              
              print('updateUser: Completed with appointment updates');
              return unit;
            }
          }
        } catch (e) {
          print('updateUser: Error checking appointment duration: $e');
          // Continue with normal update flow if this part fails
        }
      }
      
      // Normal update flow
      final updatedUser = user is PatientModel
          ? PatientModel(
        id: user.id,
        name: user.name,
        lastName: user.lastName,
        email: normalizedEmail,
        role: user.role,
        gender: user.gender,
        phoneNumber: user.phoneNumber,
        dateOfBirth: user.dateOfBirth,
        antecedent: user.antecedent,
        accountStatus: user.accountStatus,
        verificationCode: user.verificationCode,
        validationCodeExpiresAt: user.validationCodeExpiresAt,
      )
          : user is MedecinModel
          ? MedecinModel(
        id: user.id,
        name: user.name,
        lastName: user.lastName,
        email: normalizedEmail,
        role: user.role,
        gender: user.gender,
        phoneNumber: user.phoneNumber,
        dateOfBirth: user.dateOfBirth,
        speciality: user.speciality,
        numLicence: user.numLicence,
        appointmentDuration: user.appointmentDuration,
        accountStatus: user.accountStatus,
        verificationCode: user.verificationCode,
        validationCodeExpiresAt: user.validationCodeExpiresAt,
      )
          : UserModel(
        id: user.id,
        name: user.name,
        lastName: user.lastName,
        email: normalizedEmail,
        role: user.role,
        gender: user.gender,
        phoneNumber: user.phoneNumber,
        dateOfBirth: user.dateOfBirth,
        verificationCode: user.verificationCode,
        validationCodeExpiresAt: user.validationCodeExpiresAt,
      );
      print('updateUser: Updating Firestore in collection=$collection, doc=${user.id}');
      await firestore.collection(collection).doc(user.id).set(updatedUser.toJson());
      print('updateUser: Caching user locally');
      await localDataSource.cacheUser(updatedUser);
      print('updateUser: Completed successfully');
      return unit;
    } on FirebaseException catch (e) {
      print('updateUser: FirebaseException: ${e.message}');
      throw ServerException(e.message ?? 'Failed to update user');
    } catch (e) {
      print('updateUser: Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Unit> sendVerificationCode({
    required String email,
    required VerificationCodeType codeType,
  }) async {
    try {
      print('sendVerificationCode: Starting for email=$email, codeType=$codeType');
      final normalizedEmail = email.toLowerCase().trim();
      print('sendVerificationCode: Normalized email=$normalizedEmail');

      // Step 1: Define the collections to search for the user
      final collections = ['patients', 'medecins', 'users'];
      String? collectionName;
      String? userId;

      // Step 2: Search for the user by email in each collection
      print('sendVerificationCode: Searching for user in collections');
      for (var collection in collections) {
        print('sendVerificationCode: Querying collection=$collection for email=$normalizedEmail');
        final query = await firestore
            .collection(collection)
            .where('email', isEqualTo: normalizedEmail)
            .get();
        print('sendVerificationCode: Query result for $collection: ${query.docs.length} docs found');
        if (query.docs.isNotEmpty) {
          collectionName = collection;
          userId = query.docs.first.id;
          print('sendVerificationCode: User found in collection=$collectionName, userId=$userId');
          print('sendVerificationCode: Document data=${query.docs.first.data()}');
          break;
        } else {
          print('sendVerificationCode: No documents found in $collection for email=$normalizedEmail');
          // Fallback: Check all documents for case-insensitive match
          final allDocs = await firestore.collection(collection).get();
          print('sendVerificationCode: Checking all documents in $collection for case-insensitive match');
          for (var doc in allDocs.docs) {
            final data = doc.data();
            if (data['email'] != null && data['email'].toString().toLowerCase().trim() == normalizedEmail) {
              collectionName = collection;
              userId = doc.id;
              print('sendVerificationCode: User found with case-insensitive match in $collection, userId=$userId');
              print('sendVerificationCode: Document data=$data');
              // Update email to normalized form
              await firestore.collection(collection).doc(userId).update({
                'email': normalizedEmail,
              });
              print('sendVerificationCode: Email updated to $normalizedEmail');
              break;
            }
          }
          if (collectionName != null) break;
        }
      }

      // Step 3: Check if user was found
      if (collectionName == null || userId == null) {
        print('sendVerificationCode: Error - User not found for email=$normalizedEmail');
        for (var collection in collections) {
          final allDocs = await firestore.collection(collection).get();
          print('sendVerificationCode: All documents in $collection: ${allDocs.docs.length}');
          for (var doc in allDocs.docs) {
            print('sendVerificationCode: Doc in $collection: id=${doc.id}, data=${doc.data()}');
          }
        }
        throw AuthException('User not found');
      }

      // Step 4: Generate a 4-digit verification code
      final randomNumber = generateFourDigitNumber();
      print('sendVerificationCode: Generated verificationCode=$randomNumber');

      // Step 5: Update Firestore with verification code, expiration, and codeType
      print('sendVerificationCode: Updating Firestore for collection=$collectionName, userId=$userId');
      await firestore.collection(collectionName).doc(userId).update({
        'verificationCode': randomNumber,
        'validationCodeExpiresAt': DateTime.now().add(const Duration(minutes: 60)),
        'codeType': codeType.toString().split('.').last,
      }).catchError((e) {
        print('sendVerificationCode: Firestore update failed with error=$e');
        throw FirebaseException(plugin: 'firestore', message: 'Failed to update verification code: $e');
      });
      print('sendVerificationCode: Firestore updated successfully');

      // Step 6: Send the verification email
      print('sendVerificationCode: Sending email with subject=${getSubjectForCodeType(codeType)}');
      await sendVerificationEmail(
        email: normalizedEmail,
        subject: getSubjectForCodeType(codeType),
        code: randomNumber,
      ).catchError((e) {
        print('sendVerificationCode: Email sending failed with error=$e');
        throw ServerException('Failed to send verification email: $e');
      });
      print('sendVerificationCode: Email sent successfully');

      // Step 7: Return success
      print('sendVerificationCode: Completed successfully');
      return unit;
    } on FirebaseException catch (e) {
      print('sendVerificationCode: FirebaseException caught: ${e.message}');
      throw ServerException(e.message ?? 'Failed to send verification code');
    } catch (e) {
      print('sendVerificationCode: Unexpected error caught: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Unit> verifyCode({
    required String email,
    required int verificationCode,
    required VerificationCodeType codeType,
  }) async {
    try {
      print('verifyCode: Starting for email=$email, code=$verificationCode, codeType=$codeType');
      final normalizedEmail = email.toLowerCase().trim();
      final collections = ['patients', 'medecins', 'users'];
      String? collectionName;
      String? userId;
      dynamic userData;
      for (var collection in collections) {
        print('verifyCode: Querying collection=$collection for email=$normalizedEmail');
        final query = await firestore
            .collection(collection)
            .where('email', isEqualTo: normalizedEmail)
            .get();
        print('verifyCode: Query result for $collection: ${query.docs.length} docs found');
        if (query.docs.isNotEmpty) {
          collectionName = collection;
          userId = query.docs.first.id;
          userData = query.docs.first.data();
          print('verifyCode: User found in collection=$collectionName, userId=$userId');
          break;
        }
      }
      if (collectionName == null || userId == null) {
        print('verifyCode: Error - User not found for email=$normalizedEmail');
        throw AuthException('User not found');
      }
      if (userData['verificationCode'] != verificationCode) {
        print('verifyCode: Error - Invalid verification code: expected=${userData['verificationCode']}, provided=$verificationCode');
        throw AuthException('Invalid verification code');
      }
      if (userData['validationCodeExpiresAt']?.toDate().isBefore(DateTime.now()) ?? true) {
        print('verifyCode: Error - Verification code expired');
        throw AuthException('Verification code expired');
      }
      if (userData['codeType'] != codeType.toString().split('.').last) {
        print('verifyCode: Error - Invalid code type: expected=${userData['codeType']}, provided=${codeType.toString().split('.').last}');
        throw AuthException('Invalid code type');
      }
      if (codeType == VerificationCodeType.activationDeCompte || codeType == VerificationCodeType.compteActive) {
        print('verifyCode: Updating account status to active');
        await firestore.collection(collectionName).doc(userId).update({
          'accountStatus': true,
          'verificationCode': null,
          'validationCodeExpiresAt': null,
          'codeType': null,
        });
      }
      print('verifyCode: Completed successfully');
      return unit;
    } on FirebaseException catch (e) {
      print('verifyCode: FirebaseException: ${e.message}');
      throw ServerException(e.message ?? 'Failed to verify code');
    } catch (e) {
      print('verifyCode: Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Unit> changePassword({
    required String email,
    required String newPassword,
    required int verificationCode,
  }) async {
    try {
      print('changePassword: Starting for email=$email, verificationCode=$verificationCode');
      final normalizedEmail = email.toLowerCase().trim();
      final collections = ['patients', 'medecins', 'users'];
      String? collectionName;
      String? userId;
      dynamic userData;
      for (var collection in collections) {
        print('changePassword: Querying collection=$collection for email=$normalizedEmail');
        final query = await firestore
            .collection(collection)
            .where('email', isEqualTo: normalizedEmail)
            .get();
        print('changePassword: Query result for $collection: ${query.docs.length} docs found');
        if (query.docs.isNotEmpty) {
          collectionName = collection;
          userId = query.docs.first.id;
          userData = query.docs.first.data();
          print('changePassword: User found in collection=$collectionName, userId=$userId');
          break;
        }
      }
      if (collectionName == null || userId == null) {
        print('changePassword: Error - User not found for email=$normalizedEmail');
        throw AuthException('User not found');
      }
      if (userData['verificationCode'] != verificationCode) {
        print('changePassword: Error - Invalid verification code: expected=${userData['verificationCode']}, provided=$verificationCode');
        throw AuthException('Invalid verification code');
      }
      if (userData['validationCodeExpiresAt']?.toDate().isBefore(DateTime.now()) ?? true) {
        print('changePassword: Error - Verification code expired');
        throw AuthException('Verification code expired');
      }
      if (userData['codeType'] != VerificationCodeType.changerMotDePasse.toString().split('.').last &&
          userData['codeType'] != VerificationCodeType.motDePasseOublie.toString().split('.').last) {
        print('changePassword: Error - Invalid code type: expected=changerMotDePasse or motDePasseOublie, provided=${userData['codeType']}');
        throw AuthException('Invalid code type for password change');
      }
      final user = firebaseAuth.currentUser;
      if (user != null && user.email?.toLowerCase().trim() == normalizedEmail) {
        print('changePassword: Updating password for user UID=${user.uid}');
        await user.updatePassword(newPassword);
        print('changePassword: Clearing verification code');
        await clearVerificationCode(collection: collectionName, docId: userId);
        print('changePassword: Completed successfully');
        return unit;
      } else {
        print('changePassword: Error - User not authenticated or email mismatch: user.email=${user?.email}, normalizedEmail=$normalizedEmail');
        throw AuthException('User not authenticated');
      }
    } on FirebaseAuthException catch (e) {
      print('changePassword: FirebaseAuthException: ${e.message}');
      throw AuthException(e.message ?? 'Failed to change password');
    } catch (e) {
      print('changePassword: Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  // Helper method to update future appointments' endTime when a doctor's appointmentDuration changes
  Future<void> _updateFutureAppointmentsEndTime(String doctorId, int appointmentDuration) async {
    try {
      print('_updateFutureAppointmentsEndTime: Starting for doctorId=$doctorId with duration=$appointmentDuration');
      
      // Get current date/time
      final now = DateTime.now();
      
      // Query all future appointments for this doctor with status "pending" or "accepted"
      final appointmentsQuery = await firestore.collection('rendez_vous')
          .where('doctorId', isEqualTo: doctorId)
          .where('startTime', isGreaterThanOrEqualTo: now.toIso8601String())
          .get();
      
      print('_updateFutureAppointmentsEndTime: Found ${appointmentsQuery.docs.length} future appointments');
      
      // Update each appointment's endTime
      for (final doc in appointmentsQuery.docs) {
        try {
          // Parse the startTime
          DateTime startTime;
          if (doc.data()['startTime'] is String) {
            startTime = DateTime.parse(doc.data()['startTime'] as String);
          } else if (doc.data()['startTime'] is Timestamp) {
            startTime = (doc.data()['startTime'] as Timestamp).toDate();
          } else {
            print('_updateFutureAppointmentsEndTime: Skipping appointment with invalid startTime format');
            continue;
          }
          
          // Calculate new endTime
          final endTime = startTime.add(Duration(minutes: appointmentDuration));
          
          // Update the appointment
          await firestore.collection('rendez_vous').doc(doc.id).update({
            'endTime': endTime.toIso8601String(),
          });
          
          print('_updateFutureAppointmentsEndTime: Updated appointment ${doc.id}');
        } catch (e) {
          print('_updateFutureAppointmentsEndTime: Error updating appointment ${doc.id}: $e');
          // Continue with other appointments even if one fails
          continue;
        }
      }
      
      print('_updateFutureAppointmentsEndTime: Completed');
    } catch (e) {
      print('_updateFutureAppointmentsEndTime: Error: $e');
      // Don't throw exception, as this is an enhancement, not a critical operation
    }
  }
}