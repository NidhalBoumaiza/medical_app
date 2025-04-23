import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

import '../blocs/messageries BLoC/messagerie_bloc.dart';
import '../blocs/messageries BLoC/messagerie_event.dart';
import '../blocs/messageries BLoC/messagerie_state.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;

  const ChatScreen({required this.chatId, required this.userName, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    // Fetch messages on init
    context.read<MessagerieBloc>().add(FetchMessagesEvent(conversationId: widget.chatId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = MessageEntity.create(
        conversationId: widget.chatId,
        senderId: FirebaseAuth.instance.currentUser!.uid,
        content: _messageController.text,
        type: 'text',
        timestamp: DateTime.now(),
      );
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final message = MessageEntity.create(
        conversationId: widget.chatId,
        senderId: FirebaseAuth.instance.currentUser!.uid,
        content: '',
        type: 'image',
        timestamp: DateTime.now(),
      );
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message, file: file));
      _scrollToBottom();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final message = MessageEntity.create(
        conversationId: widget.chatId,
        senderId: FirebaseAuth.instance.currentUser!.uid,
        content: '',
        type: 'file',
        fileName: fileName,
        timestamp: DateTime.now(),
      );
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message, file: file));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: GoogleFonts.raleway(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<MessagerieBloc, MessagerieState>(
        listener: (context, state) {
          if (state is MessagerieError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is MessagerieSuccess && state.messageSent != null) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          List<MessageEntity> messages = [];
          if (state is MessagerieSuccess && state.messages != null) {
            messages = state.messages!;
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == FirebaseAuth.instance.currentUser!.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primaryColor : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (message.type == 'text')
                              Text(
                                message.content,
                                style: GoogleFonts.raleway(
                                  fontSize: 14.sp,
                                  color: isMe ? AppColors.white : AppColors.black,
                                ),
                              ),
                            if (message.type == 'image' && message.url != null)
                              CachedNetworkImage(
                                imageUrl: message.url!,
                                width: 150.w,
                                height: 150.h,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            if (message.type == 'file' && message.fileName != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      message.fileName!,
                                      style: GoogleFonts.raleway(
                                        fontSize: 14.sp,
                                        color: isMe ? AppColors.white : AppColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Text(
                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.raleway(
                                fontSize: 10.sp,
                                color: isMe ? AppColors.white.withOpacity(0.7) : AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                color: AppColors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: AppColors.primaryColor, size: 24.sp),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file, color: AppColors.primaryColor, size: 24.sp),
                      onPressed: _pickFile,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.raleway(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.greyLight,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: AppColors.primaryColor, size: 24.sp),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}