import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    String? id,
    required String conversationId,
    required String senderId,
    required String content,
    required String type,
    String? url,
    String? fileName,
    required DateTime timestamp,
  }) : super(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    content: content,
    type: type,
    url: url,
    fileName: fileName,
    timestamp: timestamp,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String?,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      url: json['url'] as String?,
      fileName: json['fileName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
    if (id != null) {
      data['id'] = id!;
    }
    if (url != null) {
      data['url'] = url!;
    }
    if (fileName != null) {
      data['fileName'] = fileName!;
    }
    return data;
  }
}