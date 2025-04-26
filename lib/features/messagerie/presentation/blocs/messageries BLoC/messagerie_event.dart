import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';

abstract class MessagerieEvent extends Equatable {
  const MessagerieEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends MessagerieEvent {
  final MessageModel message;
  final File? file;

  const SendMessageEvent({required this.message, this.file});

  @override
  List<Object?> get props => [message, file];
}

class FetchMessagesEvent extends MessagerieEvent {
  final String conversationId;

  const FetchMessagesEvent(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

class SubscribeToMessagesEvent extends MessagerieEvent {
  final String conversationId;

  const SubscribeToMessagesEvent(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

class AddLocalMessageEvent extends MessagerieEvent {
  final MessageModel message;

  const AddLocalMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

class UpdateMessageStatusEvent extends MessagerieEvent {
  final MessageModel message;

  const UpdateMessageStatusEvent(this.message);

  @override
  List<Object> get props => [message];
}

class MessagesUpdatedEvent extends MessagerieEvent {
  final List<MessageModel> messages;

  const MessagesUpdatedEvent({required this.messages});

  @override
  List<Object> get props => [messages];
}

class MessagesStreamErrorEvent extends MessagerieEvent {
  final String error;

  const MessagesStreamErrorEvent({required this.error});

  @override
  List<Object> get props => [error];
}