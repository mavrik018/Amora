import '../../../core/constants/enums.dart';

class OnboardingState {
  final String email;
  final String password;
  final String fullName;
  final DateTime? dob;
  final String gender;
  final String interestedIn;
  final RelationshipIntent? relationshipIntent;
  final List<String> interests;
  final Map<String, String> prompts;
  final List<String> photos;
  final String? audioBioPath;
  final double? latitude;
  final double? longitude;
  final int currentStep;
  final bool isLoading;
  final String? errorMessage;

  OnboardingState({
    this.email = '',
    this.password = '',
    this.fullName = '',
    this.dob,
    this.gender = '',
    this.interestedIn = '',
    this.relationshipIntent,
    this.interests = const [],
    this.prompts = const {},
    this.photos = const [],
    this.audioBioPath,
    this.latitude,
    this.longitude,
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    String? email,
    String? password,
    String? fullName,
    DateTime? dob,
    String? gender,
    String? interestedIn,
    RelationshipIntent? relationshipIntent,
    List<String>? interests,
    Map<String, String>? prompts,
    List<String>? photos,
    String? audioBioPath,
    double? latitude,
    double? longitude,
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      relationshipIntent: relationshipIntent ?? this.relationshipIntent,
      interests: interests ?? this.interests,
      prompts: prompts ?? this.prompts,
      photos: photos ?? this.photos,
      audioBioPath: audioBioPath ?? this.audioBioPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
