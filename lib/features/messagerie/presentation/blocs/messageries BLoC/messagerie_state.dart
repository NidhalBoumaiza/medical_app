import 'package:equatable/equatable.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

abstract class MessagerieState extends Equatable {
  const MessagerieState();

  @override
  List<Object?> get props => [];
}

class MessagerieInitial extends MessagerieState {}

class MessagerieLoading extends MessagerieState {}

class MessagerieSuccess extends MessagerieState {
  final MessageEntity? messageSent;
  final List<ConversationEntity>? conversations;
  final List<MessageEntity>? messages;

  const MessagerieSuccess({
    this.messageSent,
    this.conversations,
    this.messages,
  });

  @override
  List<Object?> get props => [messageSent, conversations, messages];
}

class MessagerieError extends MessagerieState {
  final String message;

  const MessagerieError({required this.message});

  @override
  List<Object> get props => [message];
}