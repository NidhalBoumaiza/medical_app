import 'package:equatable/equatable.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';

abstract class MessagerieState extends Equatable {
  final List<MessageModel> messages;

  const MessagerieState({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class MessagerieInitial extends MessagerieState {
  const MessagerieInitial() : super(messages: const []);
}

class MessagerieLoading extends MessagerieState {
  const MessagerieLoading({required super.messages});
}

class MessagerieStreamActive extends MessagerieState {
  const MessagerieStreamActive({required super.messages});
}

class MessagerieSuccess extends MessagerieState {
  final List<ConversationEntity>? conversations;
  final MessageModel? lastSentMessage;

  const MessagerieSuccess({
    required super.messages,
    this.conversations,
    this.lastSentMessage,
  });

  @override
  List<Object?> get props => [...super.props, conversations, lastSentMessage];
}

class MessagerieError extends MessagerieState {
  final String message;

  const MessagerieError({
    required super.messages,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}