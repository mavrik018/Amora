class VerificationRequestModel {
  final String id;
  final String userId;
  final String idImageUrl;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userFullName; // For admin view

  VerificationRequestModel({
    required this.id,
    required this.userId,
    required this.idImageUrl,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.userFullName,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: json['id'],
      userId: json['user_id'],
      idImageUrl: json['id_image_url'],
      status: json['status'],
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userFullName: json['profiles']?['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'id_image_url': idImageUrl,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
