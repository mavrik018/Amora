import 'package:amora/core/constants/enums.dart';
import 'package:amora/core/services/supabase_service.dart';
import 'package:amora/features/discover/providers/filters_provider.dart';
import 'package:amora/features/profile/models/profile_model.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:amora/features/chat/providers/connection_provider.dart';
import 'package:amora/features/profile/providers/block_provider.dart';
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

  final connectedIds = await ref.watch(connectedUserIdsProvider.future);
  final blockedIds = await ref.watch(blockedUserIdsProvider.future);

  List<ProfileModel> profiles = [];

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

  if (connectedIds.isNotEmpty || blockedIds.isNotEmpty) {
    profiles = profiles.where((p) {
      final isConnected = connectedIds.contains(p.id);
      final isBlocked = blockedIds.contains(p.id);
      return !isConnected && !isBlocked;
    }).toList();
  }

  if (userProfile != null) {
    profiles = profiles.map((p) {
      int score = 0;

      if (userProfile.interests.isNotEmpty) {
        final sharedCount = p.interests
            .where((i) => userProfile.interests.contains(i))
            .length;

        if (sharedCount > 0) {
          score += (15 + (sharedCount * 10)).clamp(0, 50);
        }
      }

      if (p.relationshipIntent == userProfile.relationshipIntent) {
        score += 30;
      } else if (p.relationshipIntent == RelationshipIntent.openToBoth ||
          userProfile.relationshipIntent == RelationshipIntent.openToBoth) {
        score += 25;
      } else {
        score += 20;
      }

      if (p.prompts.length == userProfile.prompts.length) {
        score += 10;
      } else if (p.prompts.length > userProfile.prompts.length) {
        score += 5;
      } else {
        score += 0;
      }

      if (p.audioBioUrl != null) {
        score += 15;
      }

      return p.copyWith(compatibilityScore: score);
    }).toList();

    profiles.sort(
      (a, b) =>
          (b.compatibilityScore ?? 0).compareTo(a.compatibilityScore ?? 0),
    );
  }

  return profiles;
});

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
