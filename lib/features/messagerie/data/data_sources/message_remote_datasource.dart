import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:path/path.dart' as path;

import '../models/conversation_mode.dart';

abstract class MessagingRemoteDataSource {
  Future<Unit> sendMessage(MessageModel message, File? file);
  Future<List<ConversationModel>> getConversations(String userId, bool isDoctor);
  Future<List<MessageModel>> getMessages(String conversationId);
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth firebaseAuth;

  MessagingRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.firebaseAuth,
  });

  @override
  Future<Unit> sendMessage(MessageModel message, File? file) async {
    try {
      final messageId = firestore.collection('conversations').doc().id;
      String? downloadUrl;
      String? fileName;

      // Upload file to Firebase Storage if provided
      if (file != null) {
        fileName = path.basename(file.path);
        final storageRef = storage
            .ref()
            .child('conversations/${message.conversationId}/$messageId/$fileName');
        final uploadTask = await storageRef.putFile(file);
        downloadUrl = await uploadTask.ref.getDownloadURL();
      }

      // Create updated message with ID and URL/fileName
      final updatedMessage = MessageModel(
        id: messageId,
        conversationId: message.conversationId,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        url: downloadUrl,
        fileName: fileName,
        timestamp: message.timestamp,
      );

      // Save message to Firestore
      await firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(messageId)
          .set(updatedMessage.toJson());

      // Update conversation with last message details
      await firestore.collection('conversations').doc(message.conversationId).set({
        'lastMessage': message.type == 'text' ? message.content : fileName ?? '',
        'lastMessageType': message.type,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageUrl': downloadUrl,
        'patientId': message.conversationId.split('_')[0],
        'doctorId': message.conversationId.split('_')[1],
      }, SetOptions(merge: true));

      return unit;
    } on FirebaseException catch (e) {
      throw ServerException('Firestore/Storage error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<ConversationModel>> getConversations(
      String userId, bool isDoctor) async {
    try {
      final querySnapshot = await firestore
          .collection('conversations')
          .where(isDoctor ? 'doctorId' : 'patientId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return ConversationModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final querySnapshot = await firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MessageModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firestore error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}