import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String? id; // Optional message ID
  final String conversationId; // ID of the conversation
  final String senderId; // ID of the sender (patient or doctor)
  final String content; // Text content or empty for image/file
  final String type; // 'text', 'image', or 'file'
  final String? url; // URL for image/file (e.g., Firebase Storage)
  final String? fileName; // Name of the file (for type 'file')
  final DateTime timestamp; // When the message was sent

  const MessageEntity({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    this.url,
    this.fileName,
    required this.timestamp,
  });

  factory MessageEntity.create({
    String? id,
    required String conversationId,
    required String senderId,
    required String content,
    required String type,
    String? url,
    String? fileName,
    required DateTime timestamp,
  }) {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      type: type,
      url: url,
      fileName: fileName,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    content,
    type,
    url,
    fileName,
    timestamp,
  ];
}