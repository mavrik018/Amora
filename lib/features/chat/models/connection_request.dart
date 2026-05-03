import 'package:amora/features/profile/models/profile_model.dart';

class ConnectionRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final DateTime createdAt;
  
  final ProfileModel? sender;
  final ProfileModel? receiver;

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['sender'] != null ? ProfileModel.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? ProfileModel.fromJson(json['receiver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
