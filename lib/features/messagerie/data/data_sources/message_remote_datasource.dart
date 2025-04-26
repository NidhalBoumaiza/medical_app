import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';

import '../../domain/entities/message_entity.dart';
import '../models/conversation_mode.dart';

abstract class MessagingRemoteDataSource {
  Future<Unit> sendMessage(MessageModel message, File? file);
  Future<List<ConversationEntity>> getConversations(String userId, bool isDoctor);
  Stream<List<ConversationEntity>> conversationsStream(String userId, bool isDoctor);
  Future<List<MessageModel>> getMessages(String conversationId);
  Stream<List<MessageModel>> messageStream(String conversationId);
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final FirebaseFirestore firestore;

  MessagingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Unit> sendMessage(MessageModel message, File? file) async {
    try {
      final messageData = {
        'senderId': message.senderId,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
        'type': message.type,
        'url': message.url,
        'fileName': message.fileName,
        'readBy': message.readBy,
        'status': message.status.toString().split('.').last,
      };
      await firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(message.id)
          .set(messageData);
      await firestore.collection('conversations').doc(message.conversationId).update({
        'lastMessage': message.content,
        'lastMessageType': message.type,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageUrl': message.url,
      });
      return unit;
    } catch (e) {
      throw ServerException('Failed to send message: $e');
    }
  }

  @override
  Future<List<ConversationEntity>> getConversations(String userId, bool isDoctor) async {
    try {
      final snapshot = await firestore
          .collection('conversations')
          .where(isDoctor ? 'doctorId' : 'patientId', isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ConversationModel(
          id: doc.id,
          patientId: data['patientId'] as String,
          doctorId: data['doctorId'] as String,
          patientName: data['patientName'] as String,
          doctorName: data['doctorName'] as String,
          lastMessage: data['lastMessage'] as String,
          lastMessageType: data['lastMessageType'] as String,
          lastMessageTime: DateTime.parse(data['lastMessageTime'] as String),
          lastMessageUrl: data['lastMessageUrl'] as String?,
        );
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch conversations: $e');
    }
  }

  @override
  Stream<List<ConversationEntity>> conversationsStream(String userId, bool isDoctor) {
    try {
      return firestore
          .collection('conversations')
          .where(isDoctor ? 'doctorId' : 'patientId', isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return ConversationModel(
          id: doc.id,
          patientId: data['patientId'] as String,
          doctorId: data['doctorId'] as String,
          patientName: data['patientName'] as String,
          doctorName: data['doctorName'] as String,
          lastMessage: data['lastMessage'] as String,
          lastMessageType: data['lastMessageType'] as String,
          lastMessageTime: DateTime.parse(data['lastMessageTime'] as String),
          lastMessageUrl: data['lastMessageUrl'] as String?,
        );
      }).toList())
          .handleError((error) {
        if (error is FirebaseException && error.code == 'FAILED_PRECONDITION') {
          throw ServerMessageException('Firestore query requires an index: ${error.message}');
        }
        throw ServerException('Firestore stream error: $error');
      });
    } catch (e) {
      throw ServerException('Failed to initialize stream: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final snapshot = await firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel(
          id: doc.id,
          conversationId: conversationId,
          senderId: data['senderId'] as String,
          content: data['content'] as String,
          type: data['type'] as String,
          url: data['url'] as String?,
          fileName: data['fileName'] as String?,
          timestamp: DateTime.parse(data['timestamp'] as String),
          status: MessageStatus.values.firstWhere(
                (status) => status.toString().split('.').last == data['status'],
            orElse: () => MessageStatus.sent,
          ),
          readBy: List<String>.from(data['readBy'] ?? []),
        );
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch messages: $e');
    }
  }

  @override
  Stream<List<MessageModel>> messageStream(String conversationId) {
    try {
      return firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel(
          id: doc.id,
          conversationId: conversationId,
          senderId: data['senderId'] as String,
          content: data['content'] as String,
          type: data['type'] as String,
          url: data['url'] as String?,
          fileName: data['fileName'] as String?,
          timestamp: DateTime.parse(data['timestamp'] as String),
          status: MessageStatus.values.firstWhere(
                (status) => status.toString().split('.').last == data['status'],
            orElse: () => MessageStatus.sent,
          ),
          readBy: List<String>.from(data['readBy'] ?? []),
        );
      }).toList())
          .handleError((error) {
        if (error is FirebaseException && error.code == 'FAILED_PRECONDITION') {
          throw ServerMessageException('Firestore query requires an index: ${error.message}');
        }
        throw ServerException('Firestore stream error: $error');
      });
    } catch (e) {
      throw ServerException('Failed to initialize stream: $e');
    }
  }
}