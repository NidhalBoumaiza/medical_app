import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation%20BLoC/conversations_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation%20BLoC/conversations_event.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/conversation%20BLoC/conversations_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  String _userId = '';
  bool _isDoctor = false;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final userJson = sharedPreferences.getString('CACHED_USER');
      if (userJson == null) {
        throw Exception('No cached user data found');
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final userId = userMap['id'] as String? ?? '';
      final isDoctor = userMap.containsKey('speciality') && userMap.containsKey('numLicence');

      setState(() {
        _userId = userId;
        _isDoctor = isDoctor;
        _isLoading = false;
      });

      print('ConversationsScreen loaded userId: $_userId, isDoctor: $_isDoctor');
      if (_userId.isNotEmpty) {
        context.read<ConversationsBloc>().add(SubscribeToConversationsEvent(
          userId: _userId,
          isDoctor: _isDoctor,
        ));
      } else {
        setState(() {
          _errorMessage = _t('error_user_id_missing');
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = _t('error_no_user_data');
      });
    }
  }

  String _t(String key) {
    const translations = {
      'en': {
        'messages': 'Messages',
        'error_user_id_missing': 'User ID is missing',
        'error_no_user_data': 'No user data found. Please log in.',
        'no_conversations': 'No conversations found',
        'error': 'Error: ',
        'retry': 'Retry',
        'go_to_login': 'Go to Login',
      },
      'fr': {
        'messages': 'Messages',
        'error_user_id_missing': 'L\'ID utilisateur est manquant',
        'error_no_user_data': 'Aucune donnée utilisateur trouvée. Veuillez vous connecter.',
        'no_conversations': 'Aucune conversation trouvée',
        'error': 'Erreur : ',
        'retry': 'Réessayer',
        'go_to_login': 'Aller à la connexion',
      },
    };

    final locale = Localizations.localeOf(context).languageCode;
    final lang = translations.containsKey(locale) ? locale : 'en';
    return translations[lang]![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 65.sp, color: AppColors.grey),
                SizedBox(height: 16.h),
                Text(
                  _errorMessage,
                  style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    textStyle: GoogleFonts.raleway(fontSize: 65.sp),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: Text(
                    _t('go_to_login'),
                    style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t('messages'),
          style: GoogleFonts.raleway(
            fontSize: 65.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.white,
      ),
      body: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 65.sp, color: AppColors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      _t('no_conversations'),
                      style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.black),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(

              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                final displayName = _isDoctor ? conversation.patientName : conversation.doctorName;
                final recipientId = _isDoctor ? conversation.patientId : conversation.doctorId;
                final timestamp = conversation.lastMessageTime != null
                    ? DateFormat('MMM d, HH:mm').format(conversation.lastMessageTime!)
                    : '';
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.greyLight,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: GoogleFonts.raleway(
                        fontSize: 65.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  title: Text(
                    displayName.isNotEmpty ? displayName : 'Unknown',
                    style: GoogleFonts.raleway(
                      fontSize: 65.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage.isNotEmpty ? conversation.lastMessage : 'No message',
                          style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timestamp.isNotEmpty)
                        Text(
                          timestamp,
                          style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.grey),
                        ),
                    ],
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  onTap: () {
                    print('Navigating to ChatScreen with chatId: ${conversation.id}, userName: $displayName, recipientId: $recipientId');
                    navigateToAnotherScreenWithSlideTransitionFromRightToLeft(context, ChatScreen(chatId: conversation.id! , userName: displayName, recipientId: recipientId,));

                  },
                );
              },
            );
          } else if (state is ConversationsError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 65.sp, color: AppColors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      _t('error') + state.message,
                      style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.black),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ConversationsBloc>().add(SubscribeToConversationsEvent(
                          userId: _userId,
                          isDoctor: _isDoctor,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        textStyle: GoogleFonts.raleway(fontSize: 65.sp),
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: Text(
                        _t('retry'),
                        style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Text(
              'Initializing...',
              style: GoogleFonts.raleway(fontSize: 65.sp, color: AppColors.black),
            ),
          );
        },
      ),
    );
  }
}