import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class DiscoveryFilters {
  final double minAge;
  final double maxAge;
  final double distance;
  final String gender;
  final bool verifiedOnly;

  const DiscoveryFilters({
    this.minAge = 18,
    this.maxAge = 65,
    this.distance = 10000,
    this.gender = 'Non-binary',
    this.verifiedOnly = false,
  });

  DiscoveryFilters copyWith({
    double? minAge,
    double? maxAge,
    double? distance,
    String? gender,
    bool? verifiedOnly,
  }) {
    return DiscoveryFilters(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distance: distance ?? this.distance,
      gender: gender ?? this.gender,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }
}

class DiscoveryFiltersNotifier extends StateNotifier<DiscoveryFilters> {
  DiscoveryFiltersNotifier(DiscoveryFilters initial) : super(initial);

  void setAgeRange(RangeValues range) {
    state = state.copyWith(minAge: range.start, maxAge: range.end);
  }

  void setDistance(double distance) {
    state = state.copyWith(distance: distance);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setVerifiedOnly(bool verifiedOnly) {
    state = state.copyWith(verifiedOnly: verifiedOnly);
  }

  void reset(DiscoveryFilters defaults) {
    state = defaults;
  }
}

final defaultDiscoveryFiltersProvider = Provider<DiscoveryFilters>((ref) {
  final userProfile = ref.watch(userProfileProvider).value;
  String defaultGender = 'Non-binary';

  if (userProfile != null) {
    if (userProfile.interestedIn == 'Men') {
      defaultGender = 'Man';
    } else if (userProfile.interestedIn == 'Women') {
      defaultGender = 'Woman';
    }
  }
  return DiscoveryFilters(gender: defaultGender);
});

final discoveryFiltersProvider =
    StateNotifierProvider<DiscoveryFiltersNotifier, DiscoveryFilters>((ref) {
      final defaults = ref.watch(defaultDiscoveryFiltersProvider);
      return DiscoveryFiltersNotifier(defaults);
    });
