import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:medical_app/core/utils/map_failure_to_message.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/send_message.dart';
import 'package:medical_app/features/messagerie/domain/use_cases/get_messages_stream_usecase.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/use_cases/get_message.dart';
import 'messagerie_event.dart';
import 'messagerie_state.dart';

class MessagerieBloc extends Bloc<MessagerieEvent, MessagerieState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final GetMessagesStreamUseCase getMessagesStreamUseCase;

  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  List<MessageModel> _currentMessages = [];
  String? _currentConversationId;
  bool _isSending = false;

  MessagerieBloc({
    required this.sendMessageUseCase,
    required this.getMessagesUseCase,
    required this.getMessagesStreamUseCase,
  }) : super(const MessagerieInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SubscribeToMessagesEvent>(_onSubscribeToMessages);
    on<AddLocalMessageEvent>(_onAddLocalMessage);
    on<UpdateMessageStatusEvent>(_onUpdateMessageStatus);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    on<MessagesStreamErrorEvent>(_onMessagesStreamError);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<MessagerieState> emit) async {
    // Add message locally with 'sending' status
    final sendingMessage = event.message.copyWith(status: MessageStatus.sending) as MessageModel;
    _currentMessages.insert(0, sendingMessage);
    emit(MessagerieStreamActive(messages: List.from(_currentMessages)));

    // Process message sending
    try {
      _isSending = true;
      final failureOrUnit = await sendMessageUseCase(sendingMessage, event.file);

      failureOrUnit.fold(
            (failure) {
          final failedMessage = sendingMessage.copyWith(status: MessageStatus.failed);
          _updateMessageStatus(failedMessage);
          emit(MessagerieError(
            message: mapFailureToMessage(failure),
            messages: _currentMessages,
          ));
        },
            (_) {
          final sentMessage = sendingMessage.copyWith(status: MessageStatus.sent);
          _updateMessageStatus(sentMessage);
          emit(MessagerieStreamActive(messages: List.from(_currentMessages)));
        },
      );
    } finally {
      _isSending = false;
    }

    // Process next queued message if any
    if (state is MessagerieStreamActive && _currentMessages.any((m) => m.status == MessageStatus.sending)) {
      final nextMessage = _currentMessages.firstWhere((m) => m.status == MessageStatus.sending);
      add(SendMessageEvent(message: nextMessage));
    }
  }

  void _updateMessageStatus(MessageModel updatedMessage) {
    final index = _currentMessages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _currentMessages[index] = updatedMessage;
    }
  }

  Future<void> _onFetchMessages(FetchMessagesEvent event, Emitter<MessagerieState> emit) async {
    emit(MessagerieLoading(messages: _currentMessages));
    final failureOrMessages = await getMessagesUseCase(event.conversationId);
    failureOrMessages.fold(
          (failure) => emit(MessagerieError(
        message: mapFailureToMessage(failure),
        messages: _currentMessages,
      )),
          (messages) {
        _currentMessages = messages;
        emit(MessagerieSuccess(messages: messages));
      },
    );
  }

  Future<void> _onSubscribeToMessages(SubscribeToMessagesEvent event, Emitter<MessagerieState> emit) async {
    _currentConversationId = event.conversationId;
    emit(MessagerieLoading(messages: _currentMessages));
    try {
      _messagesSubscription?.cancel();
      _messagesSubscription = getMessagesStreamUseCase(event.conversationId).listen(
            (messages) {
          add(MessagesUpdatedEvent(messages: messages));
        },
        onError: (error) {
          add(MessagesStreamErrorEvent(error: error.toString()));
        },
      );
    } catch (e) {
      emit(MessagerieError(
        message: 'Failed to initialize stream: $e',
        messages: _currentMessages,
      ));
    }
  }

  void _onAddLocalMessage(AddLocalMessageEvent event, Emitter<MessagerieState> emit) {
    if (!_currentMessages.any((m) => m.id == event.message.id)) {
      _currentMessages.insert(0, event.message);
      emit(MessagerieStreamActive(messages: List.from(_currentMessages)));
    }
  }

  void _onUpdateMessageStatus(UpdateMessageStatusEvent event, Emitter<MessagerieState> emit) {
    _updateMessageStatus(event.message);
    emit(MessagerieStreamActive(messages: List.from(_currentMessages)));
  }

  void _onMessagesUpdated(MessagesUpdatedEvent event, Emitter<MessagerieState> emit) {
    _currentMessages = event.messages;
    emit(MessagerieStreamActive(messages: event.messages));
  }

  void _onMessagesStreamError(MessagesStreamErrorEvent event, Emitter<MessagerieState> emit) {
    emit(MessagerieError(
      message: 'Stream error: ${event.error}',
      messages: _currentMessages,
    ));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}