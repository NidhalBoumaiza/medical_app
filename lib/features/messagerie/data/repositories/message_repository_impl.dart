import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/network/network_info.dart';

import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/entities/message_entity.dart';

import '../../domain/repositories/message_repository.dart';
import '../data_sources/message_local_datasource.dart';
import '../data_sources/message_remote_datasource.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource remoteDataSource;
  final MessagingLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MessagingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required MessageEntity message,
    File? file,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final messageModel = MessageModel(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          content: message.content,
          type: message.type,
          url: message.url,
          fileName: message.fileName,
          timestamp: message.timestamp,
        );
        await remoteDataSource.sendMessage(messageModel, file);
        // Cache the message locally
        final cachedMessages =
        await localDataSource.getCachedMessages(message.conversationId).catchError((e) => <MessageModel>[]);
        cachedMessages.add(messageModel);
        await localDataSource.cacheMessages(message.conversationId, cachedMessages);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations({
    required String userId,
    required bool isDoctor,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final conversations = await remoteDataSource.getConversations(userId, isDoctor);
        await localDataSource.cacheConversations(conversations);
        return Right(conversations);
      } on ServerException catch (e) {
        return Left(ServerFailure());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final cachedConversations = await localDataSource.getCachedConversations();
        return Right(cachedConversations);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String conversationId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final messages = await remoteDataSource.getMessages(conversationId);
        await localDataSource.cacheMessages(conversationId, messages);
        return Right(messages);
      } on ServerException catch (e) {
        return Left(ServerFailure());
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final cachedMessages = await localDataSource.getCachedMessages(conversationId);
        return Right(cachedMessages);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }
}