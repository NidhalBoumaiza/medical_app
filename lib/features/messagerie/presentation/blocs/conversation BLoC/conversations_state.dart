import 'package:equatable/equatable.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationEntity> conversations;

  const ConversationsLoaded({required this.conversations});

  @override
  List<Object> get props => [conversations];
}

class ConversationsError extends ConversationsState {
  final String message;

  const ConversationsError({required this.message});

  @override
  List<Object> get props => [message];
}

class NavigateToChat extends ConversationsState {
  final String conversationId;
  final String userName;

  const NavigateToChat({
    required this.conversationId,
    required this.userName,
  });

  @override
  List<Object> get props => [conversationId, userName];
}