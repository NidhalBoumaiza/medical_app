import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import '../../../domain/use_cases/get_conversations.dart';
import '../../../domain/use_cases/get_message.dart';
import '../../../domain/use_cases/send_message.dart';
import 'messagerie_event.dart';
import 'messagerie_state.dart';

class MessagerieBloc extends Bloc<MessagerieEvent, MessagerieState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;

  MessagerieBloc({
    required this.sendMessageUseCase,
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
  }) : super(MessagerieInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<FetchConversationsEvent>(_onFetchConversations);
    on<FetchMessagesEvent>(_onFetchMessages);
  }

  void _onSendMessage(
      SendMessageEvent event,
      Emitter<MessagerieState> emit,
      ) async {
    emit(MessagerieLoading());
    final failureOrUnit = await sendMessageUseCase(
      message: event.message,
      file: event.file,
    );
    failureOrUnit.fold(
          (failure) => emit(MessagerieError(message: mapFailureToMessage(failure))),
          (_) => emit(MessagerieSuccess(messageSent: event.message)),
    );
  }

  void _onFetchConversations(
      FetchConversationsEvent event,
      Emitter<MessagerieState> emit,
      ) async {
    emit(MessagerieLoading());
    final failureOrConversations = await getConversationsUseCase(
      userId: event.userId,
      isDoctor: event.isDoctor,
    );
    failureOrConversations.fold(
          (failure) => emit(MessagerieError(message: mapFailureToMessage(failure))),
          (conversations) => emit(MessagerieSuccess(conversations: conversations)),
    );
  }

  void _onFetchMessages(
      FetchMessagesEvent event,
      Emitter<MessagerieState> emit,
      ) async {
    emit(MessagerieLoading());
    final failureOrMessages = await getMessagesUseCase(
      conversationId: event.conversationId,
    );
    failureOrMessages.fold(
          (failure) => emit(MessagerieError(message: mapFailureToMessage(failure))),
          (messages) => emit(MessagerieSuccess(messages: messages)),
    );
  }
}