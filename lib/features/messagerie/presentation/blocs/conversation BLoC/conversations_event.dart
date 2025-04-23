import 'package:equatable/equatable.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object> get props => [];
}

class FetchConversationsEvent extends ConversationsEvent {
  final String userId;
  final bool isDoctor;

  const FetchConversationsEvent({
    required this.userId,
    required this.isDoctor,
  });

  @override
  List<Object> get props => [userId, isDoctor];
}

class SelectConversationEvent extends ConversationsEvent {
  final String conversationId;
  final String userName;

  const SelectConversationEvent({
    required this.conversationId,
    required this.userName,
  });

  @override
  List<Object> get props => [conversationId, userName];
}