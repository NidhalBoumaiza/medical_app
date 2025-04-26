import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import '../blocs/conversation BLoC/conversations_bloc.dart';
import '../blocs/conversation BLoC/conversations_event.dart';
import '../blocs/conversation BLoC/conversations_state.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final String userId;
  final bool isDoctor;

  const ConversationsScreen({
    required this.userId,
    required this.isDoctor,
    super.key,
  });

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationsBloc>().add(FetchConversationsEvent(
      userId: widget.userId,
      isDoctor: widget.isDoctor,
    ));
    context.read<ConversationsBloc>().add(SubscribeToConversationsEvent(
      userId: widget.userId,
      isDoctor: widget.isDoctor,
    ));
  }

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
            showErrorSnackBar(context, state.message);
          } else if (state is NavigateToChat) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: state.conversationId,
                  userName: state.userName,
                  recipientId: state.recipientId,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return Center(
                child: Text(
                  'No conversations yet',
                  style: GoogleFonts.raleway(
                    fontSize: 60.sp,
                    color: AppColors.grey,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                // Display doctorName for patients, patientName for doctors
                final displayName = widget.isDoctor ? conversation.patientName : conversation.doctorName;
                // Set recipientId as doctorId for patients, patientId for doctors
                final recipientId = widget.isDoctor ? conversation.patientId : conversation.doctorId;
                return ListTile(
                  title: Text(
                    displayName,
                    style: GoogleFonts.raleway(
                      fontSize: 48.sp,
                      color: AppColors.black,
                    ),
                  ),
                  subtitle: Text(
                    conversation.lastMessage,
                    style: GoogleFonts.raleway(
                      fontSize: 36.sp,
                      color: AppColors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    if (conversation.id != null) {
                      context.read<ConversationsBloc>().add(SelectConversationEvent(
                        conversationId: conversation.id!,
                        userName: displayName,
                        recipientId: recipientId,
                      ));
                    } else {
                      showErrorSnackBar(context, 'Conversation ID is missing');
                    }
                  },
                );
              },
            );
          } else if (state is ConversationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: GoogleFonts.raleway(
                      fontSize: 60.sp,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConversationsBloc>().add(FetchConversationsEvent(
                        userId: widget.userId,
                        isDoctor: widget.isDoctor,
                      ));
                      context.read<ConversationsBloc>().add(SubscribeToConversationsEvent(
                        userId: widget.userId,
                        isDoctor: widget.isDoctor,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.raleway(
                        fontSize: 48.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}