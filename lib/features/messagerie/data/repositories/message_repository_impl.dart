import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/core/error/failures.dart';
import 'package:medical_app/core/network/network_info.dart';
import 'package:medical_app/features/messagerie/data/data_sources/message_remote_datasource.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:medical_app/features/messagerie/domain/entities/conversation_entity.dart';
import 'package:medical_app/features/messagerie/domain/repositories/message_repository.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MessagingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> sendMessage(MessageModel message, File? file) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.sendMessage(message, file);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
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
        return Right(conversations);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Stream<List<ConversationEntity>> getConversationsStream({
    required String userId,
    required bool isDoctor,
  }) {
    return Stream.fromFuture(networkInfo.isConnected).asyncExpand((isConnected) {
      if (isConnected) {
        try {
          return remoteDataSource.conversationsStream(userId, isDoctor).handleError((error) {
            if (error is ServerException) {
              throw ServerFailure();
            } else if (error is ServerMessageException) {
              throw ServerMessageFailure(error.message);
            } else if (error is AuthException) {
              throw AuthFailure(error.message);
            } else {
              throw ServerFailure();
            }
          });
        } catch (e) {
          return Stream.error(e);
        }
      } else {
        return Stream.error(OfflineFailure());
      }
    });
  }

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(String conversationId) async {
    if (await networkInfo.isConnected) {
      try {
        final messages = await remoteDataSource.getMessages(conversationId);
        return Right(messages);
      } on ServerException {
        return Left(ServerFailure());
      } on ServerMessageException catch (e) {
        return Left(ServerMessageFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return Stream.fromFuture(networkInfo.isConnected).asyncExpand((isConnected) {
      if (isConnected) {
        try {
          return remoteDataSource.messageStream(conversationId).handleError((error) {
            if (error is ServerException) {
              throw ServerFailure();
            } else if (error is ServerMessageException) {
              throw ServerMessageFailure(error.message);
            } else if (error is AuthException) {
              throw AuthFailure(error.message);
            } else {
              throw ServerFailure();
            }
          });
        } catch (e) {
          return Stream.error(e);
        }
      } else {
        return Stream.error(OfflineFailure());
      }
    });
  }
}