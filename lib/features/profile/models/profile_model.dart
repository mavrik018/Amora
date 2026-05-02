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
    };

    if (latitude != null && longitude != null) {
      // PostGIS geography format: POINT(longitude latitude)
      map['location'] = 'POINT($longitude $latitude)';
    }

    return map;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as String?;
    final coords = _parseLocationPoint(location);

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
      locationName: json['location_name'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : coords?.latitude,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : coords?.longitude,
      savedLocations: List<Map<String, dynamic>>.from(
        json['saved_locations'] ?? [],
      ),
    );
  }

  static _LatLng? _parseLocationPoint(String? location) {
    if (location == null || location.isEmpty) return null;

    // Accept formats like 'POINT(lon lat)' or 'SRID=4326;POINT(lon lat)'
    final normalized = location.replaceAll('SRID=4326;', '');
    final match = RegExp(
      r'POINT\s*\(([-0-9\.]+)\s+([-0-9\.]+)\)',
    ).firstMatch(normalized);
    if (match == null) return null;

    final lon = double.tryParse(match.group(1)!);
    final lat = double.tryParse(match.group(2)!);
    if (lon == null || lat == null) return null;
    return _LatLng(latitude: lat, longitude: lon);
  }
}

class _LatLng {
  final double latitude;
  final double longitude;

  const _LatLng({required this.latitude, required this.longitude});
}
