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

  if (userProfile != null &&
      userProfile.latitude != null &&
      userProfile.longitude != null) {
    try {
      final profiles = await service.getRecommendedProfiles(
        gender: filters.gender,
        minAge: filters.minAge.toInt(),
        maxAge: filters.maxAge.toInt(),
        lat: userProfile.latitude!,
        lng: userProfile.longitude!,
        radiusKm: filters.distance,
      );
      print('Discovery: Found ${profiles.length} profiles via RPC');
      return profiles;
    } catch (e) {
      print('Discovery: RPC error: $e');
      // Fallback to client-side if RPC fails
    }
  } else {
    print(
      'Discovery: No user coordinates found, falling back to client-side filtering. '
      'User profile exists: ${userProfile != null}, '
      'Lat: ${userProfile?.latitude}, Lng: ${userProfile?.longitude}',
    );
  }

  // Fallback to client-side filtering if no location or RPC fails
  final profiles = await service.getProfiles();
  List<ProfileModel> filteredProfiles = profiles;

  // Filter by gender
  if (filters.gender != "Non-binary") {
    filteredProfiles = filteredProfiles
        .where((p) => p.gender == filters.gender)
        .toList();
  }

  // Filter by age
  filteredProfiles = filteredProfiles.where((p) {
    if (p.dob == null) return false;
    final age = _calculateAge(p.dob!);
    return age >= filters.minAge && age <= filters.maxAge;
  }).toList();

  // Filter by distance (if we have user coordinates)
  if (userProfile != null &&
      userProfile.latitude != null &&
      userProfile.longitude != null) {
    filteredProfiles = filteredProfiles.where((p) {
      if (p.latitude == null || p.longitude == null) {
        // Exclude profiles with no location when filtering strictly
        return false;
      }

      final distanceInMeters = Geolocator.distanceBetween(
        userProfile.latitude!,
        userProfile.longitude!,
        p.latitude!,
        p.longitude!,
      );

      final distanceInKm = distanceInMeters / 1000;
      return distanceInKm <= filters.distance;
    }).toList();
    print(
      'Discovery: After client-side distance filter: ${filteredProfiles.length} profiles',
    );
  }

  return filteredProfiles;
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
