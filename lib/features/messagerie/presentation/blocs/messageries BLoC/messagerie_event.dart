import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

abstract class MessagerieEvent extends Equatable {
  const MessagerieEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends MessagerieEvent {
  final MessageEntity message;
  final File? file;

  const SendMessageEvent({required this.message, this.file});

  @override
  List<Object?> get props => [message, file];
}

class FetchConversationsEvent extends MessagerieEvent {
  final String userId;
  final bool isDoctor;

  const FetchConversationsEvent({required this.userId, required this.isDoctor});

  @override
  List<Object> get props => [userId, isDoctor];
}

class FetchMessagesEvent extends MessagerieEvent {
  final String conversationId;

  const FetchMessagesEvent({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}