import '../../../core/constants/enums.dart';

class ProfileModel {
  final String id;
  final String fullName;
  final DateTime? dob;
  final String gender;
  final String interestedIn;
  final RelationshipIntent? relationshipIntent;
  final List<String> interests;
  final Map<String, String> prompts;
  final List<String> photos;
  final String? audioBioUrl;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.dob,
    this.gender = '',
    this.interestedIn = '',
    this.relationshipIntent,
    this.interests = const [],
    this.prompts = const {},
    this.photos = const [],
    this.audioBioUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'interested_in': interestedIn,
      'relationship_intent': relationshipIntent?.name,
      'interests': interests,
      'prompts': prompts,
      'photos': photos,
      'audio_bio_url': audioBioUrl,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      gender: json['gender'] ?? '',
      interestedIn: json['interested_in'] ?? '',
      relationshipIntent: json['relationship_intent'] != null
          ? RelationshipIntent.values.byName(json['relationship_intent'])
          : null,
      interests: List<String>.from(json['interests'] ?? []),
      prompts: Map<String, String>.from(json['prompts'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
      audioBioUrl: json['audio_bio_url'],
    );
  }
}
