import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String? id; // Optional conversation ID
  final String patientId; // ID of the patient
  final String doctorId; // ID of the doctor
  final String lastMessage; // Last message content or file name
  final String lastMessageType; // 'text', 'image', or 'file'
  final DateTime lastMessageTime; // Timestamp of last message
  final String? lastMessageUrl; // URL for last image/file

  const ConversationEntity({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageTime,
    this.lastMessageUrl,
  });

  factory ConversationEntity.create({
    String? id,
    required String patientId,
    required String doctorId,
    required String lastMessage,
    required String lastMessageType,
    required DateTime lastMessageTime,
    String? lastMessageUrl,
  }) {
    return ConversationEntity(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      lastMessage: lastMessage,
      lastMessageType: lastMessageType,
      lastMessageTime: lastMessageTime,
      lastMessageUrl: lastMessageUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    lastMessage,
    lastMessageType,
    lastMessageTime,
    lastMessageUrl,
  ];
}