import 'package:amora/core/constants/enums.dart';
import 'package:amora/core/services/supabase_service.dart';
import 'package:amora/features/discover/providers/filters_provider.dart';
import 'package:amora/features/profile/models/profile_model.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final otherProfilesProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final filters = ref.watch(discoveryFiltersProvider);
  final userProfileAsync = ref.watch(userProfileProvider);
  final userProfile = userProfileAsync.value;

  List<ProfileModel> profiles = [];

  // 1. Fetch Profiles (via RPC or Table Select)
  if (userProfile != null &&
      userProfile.latitude != null &&
      userProfile.longitude != null) {
    try {
      profiles = await service.getRecommendedProfiles(
        gender: filters.gender,
        minAge: filters.minAge.toInt(),
        maxAge: filters.maxAge.toInt(),
        lat: userProfile.latitude!,
        lng: userProfile.longitude!,
        radiusKm: filters.distance,
      );
    } catch (e) {
      print('Discovery: RPC error, falling back: $e');
      final allProfiles = await service.getProfiles();
      profiles = _applyClientFilters(allProfiles, filters, userProfile);
    }
  } else {
    final allProfiles = await service.getProfiles();
    profiles = _applyClientFilters(allProfiles, filters, userProfile);
  }

  // 2. Complete Client-Side Compatibility Scoring
  if (userProfile != null) {
    profiles = profiles.map((p) {
      int score = 0;

      // A. Shared Interests (50%) - More lenient: even 1 match is a big boost
      if (userProfile.interests.isNotEmpty) {
        final sharedCount = p.interests
            .where((i) => userProfile.interests.contains(i))
            .length;

        if (sharedCount > 0) {
          // Give 25 points for the first match, and +10 for each additional one
          score += (15 + (sharedCount * 10)).clamp(0, 50);
        }
      }

      // B. Relationship Intent (30%) - Higher base for mismatches
      if (p.relationshipIntent == userProfile.relationshipIntent) {
        score += 30;
      } else if (p.relationshipIntent == RelationshipIntent.openToBoth ||
          userProfile.relationshipIntent == RelationshipIntent.openToBoth) {
        score += 25;
      } else {
        score += 20; // Increased floor for intent mismatch
      }

      // C. Personality Prompt Completion (20%)
      if (p.prompts.isNotEmpty) {
        score += 20;
      }

      return p.copyWith(compatibilityScore: score);
    }).toList();

    // 3. Sort by Compatibility Score (Descending)
    profiles.sort(
      (a, b) =>
          (b.compatibilityScore ?? 0).compareTo(a.compatibilityScore ?? 0),
    );
  }

  return profiles;
});

/// Helper to apply filters when RPC is not available or location is missing
List<ProfileModel> _applyClientFilters(
  List<ProfileModel> profiles,
  DiscoveryFilters filters,
  ProfileModel? userProfile,
) {
  List<ProfileModel> filtered = profiles;

  // Gender Filter
  if (filters.gender != "Non-binary") {
    filtered = filtered.where((p) => p.gender == filters.gender).toList();
  }

  // Age Filter
  filtered = filtered.where((p) {
    if (p.dob == null) return false;
    final age = _calculateAge(p.dob!);
    return age >= filters.minAge && age <= filters.maxAge;
  }).toList();

  // Distance Filter
  if (userProfile != null &&
      userProfile.latitude != null &&
      userProfile.longitude != null) {
    filtered = filtered.where((p) {
      if (p.latitude == null || p.longitude == null) return false;
      final distanceInMeters = Geolocator.distanceBetween(
        userProfile.latitude!,
        userProfile.longitude!,
        p.latitude!,
        p.longitude!,
      );
      return (distanceInMeters / 1000) <= filters.distance;
    }).toList();
  }

  return filtered;
}

final bestMatchProvider = FutureProvider<ProfileModel?>((ref) async {
  final profiles = await ref.watch(otherProfilesProvider.future);
  if (profiles.isEmpty) return null;
  return profiles.first;
});

int _calculateAge(DateTime dob) {
  final today = DateTime.now();
  int age = today.year - dob.year;
  if (today.month < dob.month ||
      (today.month == dob.month && today.day < dob.day)) {
    age--;
  }
  return age;
}
