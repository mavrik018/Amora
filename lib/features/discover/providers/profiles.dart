import 'package:amora/core/services/supabase_service.dart';
import 'package:amora/features/discover/providers/filters_provider.dart';
import 'package:amora/features/profile/models/profile_model.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final profiles = await service.getRecommendedProfiles(
      gender: filters.gender == "Non-binary" ? null : filters.gender,
      minAge: filters.minAge.toInt(),
      maxAge: filters.maxAge.toInt(),
      lat: userProfile.latitude!,
      lng: userProfile.longitude!,
      radiusKm: filters.distance,
    );

    return profiles;
  } else {
    // Fallback to client-side filtering if no location
    final profiles = await service.getProfiles();
    late List<ProfileModel> filteredProfiles;
    // Filter by gender
    if (filters.gender == "Non-binary") {
      filteredProfiles = profiles;
    } else {
      filteredProfiles = profiles.where((p) {
        return p.gender == filters.gender;
      }).toList();
    }

    // Filter by age
    filteredProfiles = filteredProfiles.where((p) {
      if (p.dob == null) return false;
      final age = _calculateAge(p.dob!);
      return age >= filters.minAge && age <= filters.maxAge;
    }).toList();

    return filteredProfiles;
  }
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
