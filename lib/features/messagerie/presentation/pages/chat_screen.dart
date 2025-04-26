import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import '../../domain/entities/message_entity.dart';
import '../blocs/messageries BLoC/messagerie_bloc.dart';
import '../blocs/messageries BLoC/messagerie_event.dart';
import '../blocs/messageries BLoC/messagerie_state.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String recipientId;

  const ChatScreen({
    required this.chatId,
    required this.userName,
    required this.recipientId,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    context.read<MessagerieBloc>().add(FetchMessagesEvent(widget.chatId));
    context.read<MessagerieBloc>().add(SubscribeToMessagesEvent(widget.chatId));
    _setupReadReceipts();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupReadReceipts() {
    _firestore
        .collection('conversations')
        .doc(widget.chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: _auth.currentUser!.uid)
        .where('readBy', arrayContains: _auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final readMessage = MessageModel(
            id: change.doc.id,
            conversationId: widget.chatId,
            senderId: data['senderId'] as String,
            content: data['content'] as String,
            type: data['type'] as String,
            url: data['url'] as String?,
            fileName: data['fileName'] as String?,
            timestamp: DateTime.parse(data['timestamp'] as String),
            status: MessageStatus.read,
            readBy: List<String>.from(data['readBy'] ?? []),
          );
          context.read<MessagerieBloc>().add(UpdateMessageStatusEvent(readMessage));
        }
      }
    }, onError: (error) {
      showErrorSnackBar(context, 'Failed to update read receipts: $error');
    });
  }

  Future<void> _markMessagesAsRead() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final unreadMessages = await _firestore
          .collection('conversations')
          .doc(widget.chatId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.recipientId)
          .where('readBy', arrayContains: currentUserId, isNull: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([currentUserId]),
          'status': 'read',
        });
      }
      await batch.commit();
    } catch (e) {
      showErrorSnackBar(context, 'Failed to mark messages as read: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: widget.chatId,
        senderId: _auth.currentUser!.uid,
        content: _messageController.text,
        type: 'text',
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        readBy: [],
      );

      context.read<MessagerieBloc>().add(AddLocalMessageEvent(message));
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: widget.chatId,
        senderId: _auth.currentUser!.uid,
        content: '',
        type: 'image',
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        readBy: [],
      );

      context.read<MessagerieBloc>().add(AddLocalMessageEvent(message));
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message, file: file));
      _scrollToBottom();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: widget.chatId,
        senderId: _auth.currentUser!.uid,
        content: '',
        type: 'file',
        fileName: fileName,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        readBy: [],
      );

      context.read<MessagerieBloc>().add(AddLocalMessageEvent(message));
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message, file: file));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12.w,
          height: 12.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 12.w,
          color: Colors.white70,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 12.w,
          color: Colors.white70,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 12.w,
          color: Colors.blue,
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 12.w,
          color: Colors.red,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: GoogleFonts.raleway(
            fontSize: 60.sp,
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
            showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          List<MessageModel> messages = [];
          bool isLoading = false;

          if (state is MessagerieLoading) {
            isLoading = true;
            messages = state.messages;
          } else if (state is MessagerieStreamActive || state is MessagerieSuccess) {
            messages = state.messages;
          } else if (state is MessagerieError) {
            messages = state.messages;
          }

          return Column(
            children: [
              Expanded(
                child: isLoading && messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    ? Center(
                  child: Text(
                    'No messages yet',
                    style: GoogleFonts.raleway(
                      fontSize: 60.sp,
                      color: AppColors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _auth.currentUser!.uid;
                    return Align(
                      key: ValueKey(message.id), // Ensure stable rendering
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                        padding: EdgeInsets.all(12.w),
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
                                  fontSize: 48.sp,
                                  color: isMe ? AppColors.white : AppColors.black,
                                ),
                              ),
                            if (message.type == 'image' && message.url != null)
                              CachedNetworkImage(
                                imageUrl: message.url!,
                                width: 300.w,
                                height: 300.h,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            if (message.type == 'file' && message.fileName != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description,
                                      size: 48.sp, color: isMe ? AppColors.white : AppColors.black),
                                  SizedBox(width: 12.w),
                                  Flexible(
                                    child: Text(
                                      message.fileName!,
                                      style: GoogleFonts.raleway(
                                        fontSize: 48.sp,
                                        color: isMe ? AppColors.white : AppColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 36.sp,
                                    color: isMe ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 6.w),
                                  _buildMessageStatusIcon(message.status),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (state is MessagerieError)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<MessagerieBloc>().add(FetchMessagesEvent(widget.chatId));
                      context.read<MessagerieBloc>().add(SubscribeToMessagesEvent(widget.chatId));
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
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                color: AppColors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: AppColors.primaryColor, size: 48.sp),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file, color: AppColors.primaryColor, size: 48.sp),
                      onPressed: _pickFile,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.raleway(
                            fontSize: 48.sp,
                            color: AppColors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.greyLight,
                          contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        ),
                        style: GoogleFonts.raleway(
                          fontSize: 48.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: AppColors.primaryColor, size: 48.sp),
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