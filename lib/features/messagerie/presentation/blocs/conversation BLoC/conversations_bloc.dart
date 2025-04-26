import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_conversations.dart';
import 'conversations_event.dart';
import 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final GetConversationsUseCase getConversationsUseCase;
  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;
  List<ConversationEntity> _currentConversations = [];

  ConversationsBloc({required this.getConversationsUseCase})
      : super(const ConversationsInitial()) {
    on<FetchConversationsEvent>(_onFetchConversations);
    on<SubscribeToConversationsEvent>(_onSubscribeToConversations);
    on<ConversationsUpdatedEvent>(_onConversationsUpdated);
    on<ConversationsStreamErrorEvent>(_onConversationsStreamError);
    on<SelectConversationEvent>(_onSelectConversation);
  }

  Future<void> _onFetchConversations(
      FetchConversationsEvent event,
      Emitter<ConversationsState> emit,
      ) async {
    emit(ConversationsLoading(conversations: _currentConversations));
    final failureOrConversations = await getConversationsUseCase(
      userId: event.userId,
      isDoctor: event.isDoctor,
    );
    failureOrConversations.fold(
          (failure) => emit(ConversationsError(
        message: mapFailureToMessage(failure),
        conversations: _currentConversations,
      )),
          (conversations) {
        _currentConversations = conversations;
        emit(ConversationsLoaded(conversations: conversations));
      },
    );
  }

  Future<void> _onSubscribeToConversations(
      SubscribeToConversationsEvent event,
      Emitter<ConversationsState> emit,
      ) async {
    emit(ConversationsLoading(conversations: _currentConversations));
    try {
      _conversationsSubscription?.cancel();
      final conversationsStream = getConversationsUseCase.stream(
        userId: event.userId,
        isDoctor: event.isDoctor,
      );
      _conversationsSubscription = conversationsStream.listen(
            (conversations) {
          add(ConversationsUpdatedEvent(conversations: conversations));
        },
        onError: (error) {
          add(ConversationsStreamErrorEvent(error: error.toString()));
        },
      );
    } catch (e) {
      emit(ConversationsError(
        message: 'Failed to subscribe to conversations: $e',
        conversations: _currentConversations,
      ));
    }
  }

  void _onConversationsUpdated(
      ConversationsUpdatedEvent event,
      Emitter<ConversationsState> emit,
      ) {
    _currentConversations = event.conversations;
    emit(ConversationsLoaded(conversations: event.conversations));
  }

  void _onConversationsStreamError(
      ConversationsStreamErrorEvent event,
      Emitter<ConversationsState> emit,
      ) {
    emit(ConversationsError(
      message: 'Failed to load conversations: ${event.error}',
      conversations: _currentConversations,
    ));
  }

  void _onSelectConversation(
      SelectConversationEvent event,
      Emitter<ConversationsState> emit,
      ) {
    emit(NavigateToChat(
      conversationId: event.conversationId,
      userName: event.userName,
      recipientId: event.recipientId,
      conversations: _currentConversations,
    ));
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}