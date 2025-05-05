import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/messageries%20BLoC/messagerie_bloc.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/messageries%20BLoC/messagerie_event.dart';
import 'package:medical_app/features/messagerie/presentation/blocs/messageries%20BLoC/messagerie_state.dart';
import 'package:file_picker/file_picker.dart';

// ChatScreen displays the messaging interface for a conversation
class ChatScreen extends StatefulWidget {
  final String chatId; // Unique ID of the conversation
  final String userName; // Name of the recipient
  final String recipientId; // ID of the recipient user

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
  final TextEditingController _messageController = TextEditingController(); // Controller for message input
  final ScrollController _scrollController = ScrollController(); // Controller for scrolling message list
  final ImagePicker _picker = ImagePicker(); // For picking images
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  List<XFile> _selectedImages = []; // Store selected images for preview

  @override
  void initState() {
    super.initState();
    print('ChatScreen initialized with chatId: ${widget.chatId}, userName: ${widget.userName}, recipientId: ${widget.recipientId}');
    // Check if user is authenticated
    if (_auth.currentUser == null) {
      print('User not authenticated, redirecting to login');
      showErrorSnackBar(context, 'User not authenticated');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    // Fetch messages and subscribe to updates
    print('Dispatching FetchMessagesEvent and SubscribeToMessagesEvent for chatId: ${widget.chatId}');
    context.read<MessagerieBloc>().add(FetchMessagesEvent(widget.chatId));
    context.read<MessagerieBloc>().add(SubscribeToMessagesEvent(widget.chatId));
    _setupReadReceipts();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    print('Disposing ChatScreen, cleaning up controllers');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Sets up a listener to mark incoming messages as read
  void _setupReadReceipts() {
    print('Setting up read receipts for chatId: ${widget.chatId}');
    _firestore
        .collection('conversations')
        .doc(widget.chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: _auth.currentUser!.uid)
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
          print('Updating read status for message ${readMessage.id} to read');
          context.read<MessagerieBloc>().add(UpdateMessageStatusEvent(readMessage));
        }
      }
    }, onError: (error) {
      print('Read receipts error: $error');
      showErrorSnackBar(context, 'Failed to update read receipts: $error');
    });
  }

  // Marks all unread messages from the recipient as read
  Future<void> _markMessagesAsRead() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('No current user ID, cannot mark messages as read');
      return;
    }

    try {
      print('Marking messages as read for recipientId: ${widget.recipientId}');
      final messages = await _firestore
          .collection('conversations')
          .doc(widget.chatId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.recipientId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        final readBy = List<String>.from(doc.data()['readBy'] ?? []);
        if (!readBy.contains(currentUserId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([currentUserId]),
            'status': 'read',
          });
        }
      }
      await batch.commit();
      print('Marked ${messages.docs.length} messages as read');
    } catch (e) {
      print('Error marking messages as read: $e');
      showErrorSnackBar(context, 'Failed to mark messages as read: $e');
    }
  }

  // Sends a text message
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        conversationId: widget.chatId,
        senderId: _auth.currentUser!.uid,
        content: _messageController.text,
        type: 'text',
        timestamp: DateTime.now(),
        status: MessageStatus.sending, // Initial status
        readBy: [],
      );

      print('Sending text message ${message.id}: ${message.content}');
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  // Picks multiple images and shows preview
  Future<void> _pickImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });
      print('Selected ${images.length} images');
      _showImagePreview();
    }
  }

  // Shows a modal bottom sheet to preview selected images
  void _showImagePreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16.w),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Text(
                    'Selected Images (${_selectedImages.length})',
                    style: GoogleFonts.raleway(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        final image = _selectedImages[index];
                        return Stack(
                          children: [
                            Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                              width: 100.w,
                              height: 100.h,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  });
                                  if (_selectedImages.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  color: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 40.sp,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _selectedImages.isEmpty
                        ? null
                        : () {
                      _sendImages();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    ),
                    child: Text(
                      'Send (${_selectedImages.length})',
                      style: GoogleFonts.raleway(
                        fontSize: 50.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _selectedImages = [];
      });
      print('Image preview closed, cleared selected images');
    });
  }

  // Sends all selected images as individual messages
  void _sendImages() {
    for (var image in _selectedImages) {
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

      print('Sending image message ${message.id}');
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message, file: file));
    }
    _scrollToBottom();
  }

  // Picks and sends a file
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

      print('Sending file message ${message.id}: $fileName');
      context.read<MessagerieBloc>().add(SendMessageEvent(message: message, file: file));
      _scrollToBottom();
    }
  }

  // Scrolls to the latest message
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Displays an image in a dialog
  void _viewMedia(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(
            Icons.error,
            size: 50.sp,
            color: AppColors.grey,
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Placeholder for file download
  void _downloadFile(String url, String fileName) {
    showErrorSnackBar(context, 'File download not implemented yet');
  }

  // Builds the status icon (loader, checkmark, etc.)
  Widget _buildMessageStatusIcon(MessageStatus status) {
    print('Building status icon for status: $status');
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 50.sp,
          height: 50.sp,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white.withOpacity(0.7),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 50.sp,
          color: AppColors.white.withOpacity(0.7),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 50.sp,
          color: AppColors.white.withOpacity(0.7),
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 50.sp,
          color: AppColors.primaryColor,
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 50.sp,
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
          //style: GoogleFonts.raleway(
           // fontSize: 50.sp,
            //fontWeight: FontWeight.w600,
            //color: AppColors.black,
          //),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: BlocConsumer<MessagerieBloc, MessagerieState>(
        listener: (context, state) {
          if (state is MessagerieError) {
            print('MessagerieError: ${state.message}');
            showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          List<MessageModel> messages = [];
          bool isLoading = false;

          // Handle different states
          if (state is MessagerieLoading) {
            isLoading = true;
            messages = state.messages;
            print('MessagerieLoading with ${messages.length} messages');
          } else if (state is MessagerieStreamActive || state is MessagerieSuccess || state is MessagerieMessageSent) {
            messages = state.messages;
            print('Rendering ${messages.length} messages, state: ${state.runtimeType}, stateId: ${state.stateId}');
          } else if (state is MessagerieError) {
            messages = state.messages;
            print('MessagerieError with ${messages.length} messages');
          }

          return Column(
            children: [
              Expanded(
                child: isLoading && messages.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    ? Center(
                  child: Text(
                    'No messages yet',
                    style: GoogleFonts.raleway(
                      fontSize: 50.sp,
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
                      key: ValueKey(message.id),
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
                                  fontSize: 50.sp,
                                  color: isMe ? AppColors.white : AppColors.black,
                                ),
                              ),
                            if (message.type == 'image' && message.url != null)
                              GestureDetector(
                                onTap: () => _viewMedia(message.url!),
                                child: CachedNetworkImage(
                                  imageUrl: message.url!,
                                  width: 200.w,
                                  height: 200.h,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 50.sp,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            if (message.type == 'file' && message.fileName != null)
                              GestureDetector(
                                onTap: () => _downloadFile(message.url!, message.fileName!),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 50.sp,
                                      color: isMe ? AppColors.white : AppColors.black,
                                    ),
                                    SizedBox(width: 12.w),
                                    Flexible(
                                      child: Text(
                                        message.fileName!,
                                        style: GoogleFonts.raleway(
                                          fontSize: 50.sp,
                                          color: isMe ? AppColors.white : AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(message.timestamp),
                                  style: GoogleFonts.raleway(
                                    fontSize: 50.sp,
                                    color: isMe ? AppColors.white.withOpacity(0.7) : AppColors.grey,
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
                      print('Retrying fetch and subscribe for chatId: ${widget.chatId}');
                      context.read<MessagerieBloc>().add(FetchMessagesEvent(widget.chatId));
                      context.read<MessagerieBloc>().add(SubscribeToMessagesEvent(widget.chatId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.raleway(
                        fontSize: 50.sp,
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
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.image,
                    //     color: AppColors.primaryColor,
                    //     size: 50.sp,
                    //   ),
                    //   onPressed: _pickImage,
                    // ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.attach_file,
                    //     color: AppColors.primaryColor,
                    //     size: 50.sp,
                    //   ),
                    //   onPressed: _pickFile,
                    // ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.raleway(
                            fontSize: 50.sp,
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
                          fontSize: 50.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: AppColors.primaryColor,
                        size: 50.sp,
                      ),
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