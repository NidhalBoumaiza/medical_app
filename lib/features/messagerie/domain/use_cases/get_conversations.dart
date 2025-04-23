import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';

import '../repositories/message_repository.dart';

class GetConversationsUseCase {
  final MessagingRepository messagingRepository;

  GetConversationsUseCase(this.messagingRepository);

  Future<Either<Failure, List<ConversationEntity>>> call({
    required String userId,
    required bool isDoctor,
  }) async {
    return await messagingRepository.getConversations(
      userId: userId,
      isDoctor: isDoctor,
    );
  }
}