import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

import '../repositories/message_repository.dart';

class SendMessageUseCase {
  final MessagingRepository messagingRepository;

  SendMessageUseCase(this.messagingRepository);

  Future<Either<Failure, Unit>> call({
    required MessageEntity message,
    File? file,
  }) async {
    return await messagingRepository.sendMessage(message: message, file: file);
  }
}