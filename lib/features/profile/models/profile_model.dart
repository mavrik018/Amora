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
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final List<Map<String, dynamic>> savedLocations;
  final int? compatibilityScore;

  int? get age {
    if (dob == null) return null;
    final today = DateTime.now();
    int age = today.year - dob!.year;
    if (today.month < dob!.month ||
        (today.month == dob!.month && today.day < dob!.day)) {
      age--;
    }
    return age;
  }

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
    this.latitude,
    this.longitude,
    this.locationName,
    this.savedLocations = const [],
    this.compatibilityScore,
  });

  ProfileModel copyWith({
    String? id,
    String? fullName,
    DateTime? dob,
    String? gender,
    String? interestedIn,
    RelationshipIntent? relationshipIntent,
    List<String>? interests,
    Map<String, String>? prompts,
    List<String>? photos,
    String? audioBioUrl,
    double? latitude,
    double? longitude,
    String? locationName,
    List<Map<String, dynamic>>? savedLocations,
    int? compatibilityScore,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      relationshipIntent: relationshipIntent ?? this.relationshipIntent,
      interests: interests ?? this.interests,
      prompts: prompts ?? this.prompts,
      photos: photos ?? this.photos,
      audioBioUrl: audioBioUrl ?? this.audioBioUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      savedLocations: savedLocations ?? this.savedLocations,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
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
      'location_name': locationName,
      'saved_locations': savedLocations,
      'compatibility_score': compatibilityScore,
    };

    if (latitude != null && longitude != null) {
      map['location'] = 'POINT($longitude $latitude)';
    }

    return map;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      gender: json['gender'] ?? '',
      interestedIn: json['interested_in'] ?? '',
      relationshipIntent: json['relationship_intent'] != null
          ? RelationshipIntent.fromString(json['relationship_intent'])
          : null,
      interests: List<String>.from(json['interests'] ?? []),
      prompts: Map<String, String>.from(json['prompts'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
      audioBioUrl: json['audio_bio_url'],
      locationName: json['location_name'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      savedLocations: List<Map<String, dynamic>>.from(
        json['saved_locations'] ?? [],
      ),
      compatibilityScore: json['compatibility_score'],
    );
  }
}
