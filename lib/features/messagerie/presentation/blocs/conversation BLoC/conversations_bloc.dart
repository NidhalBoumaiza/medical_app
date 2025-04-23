import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';

import '../../../domain/use_cases/get_conversations.dart';
import 'conversations_event.dart';
import 'conversations_state.dart';



class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final GetConversationsUseCase getConversationsUseCase;

  ConversationsBloc({
    required this.getConversationsUseCase,
  }) : super(ConversationsInitial()) {
    on<FetchConversationsEvent>(_onFetchConversations);
    on<SelectConversationEvent>(_onSelectConversation);
  }

  void _onFetchConversations(
      FetchConversationsEvent event,
      Emitter<ConversationsState> emit,
      ) async {
    emit(ConversationsLoading());
    final failureOrConversations = await getConversationsUseCase(
      userId: event.userId,
      isDoctor: event.isDoctor,
    );
    failureOrConversations.fold(
          (failure) => emit(ConversationsError(message: mapFailureToMessage(failure))),
          (conversations) => emit(ConversationsLoaded(conversations: conversations)),
    );
  }

  void _onSelectConversation(
      SelectConversationEvent event,
      Emitter<ConversationsState> emit,
      ) async {
    emit(NavigateToChat(
      conversationId: event.conversationId,
      userName: event.userName,
    ));
  }
}