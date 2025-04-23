import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

import '../repositories/message_repository.dart';

class GetMessagesUseCase {
  final MessagingRepository messagingRepository;

  GetMessagesUseCase(this.messagingRepository);

  Future<Either<Failure, List<MessageEntity>>> call({
    required String conversationId,
  }) async {
    return await messagingRepository.getMessages(
      conversationId: conversationId,
    );
  }
}