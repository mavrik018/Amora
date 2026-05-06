import 'package:amora/features/profile/models/profile_model.dart';

enum NotificationType { message, connectionRequest }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final ProfileModel? sender;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.sender,
    required this.data,
  });
}
