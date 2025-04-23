import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';


import '../blocs/conversation BLoC/conversations_bloc.dart';
import '../blocs/conversation BLoC/conversations_event.dart';
import '../blocs/conversation BLoC/conversations_state.dart';
import 'chat_screen.dart';

class ConversationsListScreen extends StatelessWidget {
  final bool isDoctor;

  const ConversationsListScreen({required this.isDoctor, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversations',
          style: GoogleFonts.raleway(
            fontSize: 60.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<ConversationsBloc, ConversationsState>(
        listener: (context, state) {
          if (state is ConversationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is NavigateToChat) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: state.conversationId,
                  userName: state.userName,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          List<ConversationEntity> conversations = [];
          if (state is ConversationsLoaded) {
            conversations = state.conversations;
          }
          if (conversations.isEmpty) {
            return Center(
              child: Text(
                'No conversations available',
                style: GoogleFonts.raleway(
                  fontSize: 60.sp,
                  color: AppColors.grey,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final userName = isDoctor
                  ? 'Patient ${conversation.patientId}'
                  : 'Dr. ${conversation.doctorId}';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.greyLight,
                  child: Icon(
                    conversation.lastMessageType == 'image'
                        ? Icons.image
                        : conversation.lastMessageType == 'file'
                        ? Icons.description
                        : Icons.message,
                    color: AppColors.primaryColor,
                    size: 60.sp,
                  ),
                ),
                title: Text(
                  userName,
                  style: GoogleFonts.raleway(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                subtitle: Text(
                  conversation.lastMessage.isNotEmpty
                      ? conversation.lastMessage
                      : conversation.lastMessageType == 'image'
                      ? 'Image'
                      : 'File',
                  style: GoogleFonts.raleway(
                    fontSize: 60.sp,
                    color: AppColors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatTime(conversation.lastMessageTime),
                  style: GoogleFonts.raleway(
                    fontSize: 60.sp,
                    color: AppColors.grey,
                  ),
                ),
                onTap: () {
                  context.read<ConversationsBloc>().add(
                    SelectConversationEvent(
                      conversationId: conversation.id!,
                      userName: userName,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}