import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../models/onboarding_state.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/models/profile_model.dart';
import '../../../core/constants/enums.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(OnboardingState());

  Future<void> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        errorMessage:
            'Location services are disabled. Please enable them in settings.',
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          errorMessage:
              'Location permission is required to find matches in your area.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        errorMessage:
            'Location permissions are permanently denied. Please enable them in system settings to proceed.',
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Could not fetch location. Please try again.',
      );
    }
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email.trim());
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password.trim());
  }

  void updateFullName(String fullName) {
    state = state.copyWith(fullName: fullName);
  }

  void updateDob(DateTime dob) {
    state = state.copyWith(dob: dob);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateInterestedIn(String interestedIn) {
    state = state.copyWith(interestedIn: interestedIn);
  }

  void updateRelationshipIntent(RelationshipIntent intent) {
    state = state.copyWith(relationshipIntent: intent);
  }

  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(state.interests);
    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else if (currentInterests.length < 3) {
      currentInterests.add(interest);
    }
    state = state.copyWith(interests: currentInterests);
  }

  void updatePrompt(String question, String answer) {
    final currentPrompts = Map<String, String>.from(state.prompts);
    if (answer.isEmpty) {
      currentPrompts.remove(question);
    } else {
      currentPrompts[question] = answer;
    }
    state = state.copyWith(prompts: currentPrompts);
  }

  void addPhoto(String path) {
    if (state.photos.length < 6) {
      state = state.copyWith(photos: [...state.photos, path]);
    }
  }

  void removePhoto(String path) {
    state = state.copyWith(
      photos: state.photos.where((p) => p != path).toList(),
    );
  }

  void updateAudioBio(String? path) =>
      state = state.copyWith(audioBioPath: path);

  Future<void> signUp() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final profileRepo = _ref.read(profileRepositoryProvider);

      final response = await supabase.auth.signUp(
        email: state.email.trim(),
        password: state.password.trim(),
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final List<String> uploadedPhotoUrls = [];

        for (String photoPath in state.photos) {
          final file = File(photoPath);
          final fileName =
              '$userId/${DateTime.now().millisecondsSinceEpoch}${path.extension(photoPath)}';

          await supabase.storage.from('profiles').upload(fileName, file);
          final publicUrl = supabase.storage
              .from('profiles')
              .getPublicUrl(fileName);
          uploadedPhotoUrls.add(publicUrl);
        }

        String? uploadedAudioUrl;
        if (state.audioBioPath != null && state.audioBioPath!.isNotEmpty) {
          final file = File(state.audioBioPath!);
          final fileName =
              '$userId/audio_bio_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await supabase.storage.from('profiles').upload(fileName, file);
          uploadedAudioUrl = supabase.storage
              .from('profiles')
              .getPublicUrl(fileName);
        }

        final profile = ProfileModel(
          id: userId,
          fullName: state.fullName,
          dob: state.dob,
          gender: state.gender,
          interestedIn: state.interestedIn,
          relationshipIntent: state.relationshipIntent,
          interests: state.interests,
          prompts: state.prompts,
          photos: uploadedPhotoUrls,
          audioBioUrl: uploadedAudioUrl,
          latitude: state.latitude,
          longitude: state.longitude,
        );

        await profileRepo.createProfile(profile);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier(ref);
    });
