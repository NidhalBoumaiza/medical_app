import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:medical_app/core/error/exceptions.dart';
import 'package:medical_app/features/messagerie/data/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation_mode.dart';

abstract class MessagingLocalDataSource {
  Future<Unit> cacheConversations(List<ConversationModel> conversations);
  Future<List<ConversationModel>> getCachedConversations();
  Future<Unit> cacheMessages(String conversationId, List<MessageModel> messages);
  Future<List<MessageModel>> getCachedMessages(String conversationId);
}

class MessagingLocalDataSourceImpl implements MessagingLocalDataSource {
  final SharedPreferences sharedPreferences;

  MessagingLocalDataSourceImpl({required this.sharedPreferences});

  static const String CONVERSATIONS_KEY = 'CACHED_CONVERSATIONS';
  static const String MESSAGES_KEY_PREFIX = 'CACHED_MESSAGES_';

  @override
  Future<Unit> cacheConversations(List<ConversationModel> conversations) async {
    final conversationsJson = conversations.map((c) => c.toJson()).toList();
    await sharedPreferences.setString(
        CONVERSATIONS_KEY, jsonEncode(conversationsJson));
    return unit;
  }

  @override
  Future<List<ConversationModel>> getCachedConversations() async {
    final jsonString = sharedPreferences.getString(CONVERSATIONS_KEY);
    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList
            .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw EmptyCacheException('Failed to parse cached conversations: $e');
      }
    } else {
      throw EmptyCacheException('No cached conversations found');
    }
  }

  @override
  Future<Unit> cacheMessages(
      String conversationId, List<MessageModel> messages) async {
    final messagesJson = messages.map((m) => m.toJson()).toList();
    await sharedPreferences.setString(
        '$MESSAGES_KEY_PREFIX$conversationId', jsonEncode(messagesJson));
    return unit;
  }

  @override
  Future<List<MessageModel>> getCachedMessages(String conversationId) async {
    final jsonString =
    sharedPreferences.getString('$MESSAGES_KEY_PREFIX$conversationId');
    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw EmptyCacheException('Failed to parse cached messages: $e');
      }
    } else {
      throw EmptyCacheException('No cached messages found for $conversationId');
    }
  }
}