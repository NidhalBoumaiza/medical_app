import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

abstract class MessagingRepository {
  /// Sends a message to a conversation with an optional file (image or file).
  Future<Either<Failure, Unit>> sendMessage({
    required MessageEntity message,
    File? file,
  });

  /// Retrieves a list of conversations for a user (patient or doctor).
  Future<Either<Failure, List<ConversationEntity>>> getConversations({
    required String userId,
    required bool isDoctor,
  });

  /// Retrieves messages for a specific conversation.
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String conversationId,
  });
}